// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.core.Dispatchers
import com.byteplus.vodcast.core.ErrorHandler
import com.byteplus.vodcast.core.StateMachine
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.tasks.Task
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicReference

/**
 * ChromeCast session manager.
 *
 * This class translates platform session callbacks into [CastSessionState], enforces
 * connect timeout, handles suspend/resume, classifies session end reasons, and routes
 * all session-level failures through [ErrorHandler]. Media commands are handled by
 * [ChromecastController].
 */
internal class ChromecastSessionManager(
    private val context: Context,
    private val stateMachine: StateMachine,
    private val errorHandler: ErrorHandler,
    private val discovery: ChromecastDiscovery,
) {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val sessionRef = AtomicReference<CastSession?>(null)
    private val deviceRef = AtomicReference<CastDevice?>(null)
    private val readyListeners = mutableListOf<(CastContext) -> Unit>()

    @Volatile private var castContext: CastContext? = null
    @Volatile private var connectTimeoutTask: Runnable? = null
    @Volatile private var pendingDevice: CastDevice? = null

    /** The active session, available while the sender is connected or suspended. */
    fun currentSession(): CastSession? = sessionRef.get()

    /** The current target device, set as soon as a connection attempt starts. */
    fun currentDevice(): CastDevice? = deviceRef.get()

    /** Runs the callback once CastContext is ready, or immediately if it is already available. */
    fun onCastContextReady(action: (CastContext) -> Unit) {
        val ctx = castContext
        if (ctx != null) {
            Dispatchers.postMain { runCatching { action(ctx) } }
            return
        }
        synchronized(readyListeners) { readyListeners.add(action) }
    }

    fun start() {
        // Initialize CastContext asynchronously, then attach the session manager listener.
        val initExecutor = Executors.newSingleThreadExecutor { r ->
            Thread(r, "vod-cast-init").apply { isDaemon = true }
        }
        runCatching {
            CastContext.getSharedInstance(context.applicationContext, initExecutor)
                .addOnCompleteListener { task: Task<CastContext?> ->
                    if (task.isSuccessful) {
                        val ctx = task.result ?: return@addOnCompleteListener
                        castContext = ctx
                        Dispatchers.postMain {
                            ctx.sessionManager.addSessionManagerListener(
                                sessionListener,
                                CastSession::class.java
                            )
                            val pending: List<(CastContext) -> Unit>
                            synchronized(readyListeners) {
                                pending = readyListeners.toList()
                                readyListeners.clear()
                            }
                            pending.forEach { runCatching { it(ctx) } }
                        }
                    } else {
                        errorHandler.handle(
                            CastError(
                                code = CastErrorCode.DEVICE_UNAVAILABLE,
                                reason = "CastContext init failed",
                                cause = task.exception,
                            )
                        )
                    }
                }
        }.onFailure {
            errorHandler.handle(
                CastError(CastErrorCode.DEVICE_UNAVAILABLE, "CastContext init crashed", cause = it)
            )
        }
    }

    fun stop() {
        castContext?.sessionManager?.removeSessionManagerListener(
            sessionListener, CastSession::class.java
        )
        cancelConnectTimeout()
    }

    /** Returns whether the session is connecting or already attached to a receiver. */
    fun isConnectedOrConnecting(): Boolean {
        val session = sessionRef.get() ?: return false
        return session.isConnected || session.isConnecting
    }

/**
     * Selects and connects to [device].
     *
     * If CastContext is not ready yet, the device is queued and retried once the context
     * becomes available. Otherwise route selection immediately triggers session startup.
     */
    fun connect(device: CastDevice) {
        Dispatchers.postMain {
            pendingDevice = device
            deviceRef.set(device)
            stateMachine.transitionTo(CastSessionState.CONNECTING)
            armConnectTimeout()
            val ctx = castContext
            if (ctx == null) {
                // Wait until CastContext becomes available.
                onCastContextReady {
                    val ok = discovery.selectRoute(device.id)
                    if (!ok) reportConnectFailure("route not found: ${device.id}")
                }
            } else {
                val ok = discovery.selectRoute(device.id)
                if (!ok) reportConnectFailure("route not found: ${device.id}")
            }
        }
    }

/**
     * Disconnects the current session.
     * @param endSession true to end the receiver session, false to only leave the selected route locally.
     */
    fun disconnect(endSession: Boolean) {
        Dispatchers.postMain {
            cancelConnectTimeout()
            stateMachine.transitionTo(CastSessionState.ENDING)
            if (endSession) {
                runCatching { castContext?.sessionManager?.endCurrentSession(true) }
            } else {
                runCatching { discovery.unselectCurrent() }
            }
        }
    }

    private fun armConnectTimeout() {
        cancelConnectTimeout()
        val timeoutMs = CastSdk.options().connectTimeoutMs
        val task = Runnable {
            connectTimeoutTask = null
            // Trigger timeout handling only if the session is still connecting.
            if (stateMachine.state == CastSessionState.CONNECTING) {
                reportConnectFailure("connect timeout ${timeoutMs}ms")
            }
        }
        connectTimeoutTask = task
        mainHandler.postDelayed(task, timeoutMs)
    }

    private fun cancelConnectTimeout() {
        connectTimeoutTask?.let { mainHandler.removeCallbacks(it) }
        connectTimeoutTask = null
    }

    private fun reportConnectFailure(reason: String) {
        stateMachine.transitionTo(CastSessionState.ERROR)
        errorHandler.handle(CastError(CastErrorCode.SESSION_START_FAILED, reason))
        // Drop stale routes (e.g. a receiver that went offline) so the UI list stays accurate.
        runCatching { discovery.refresh() }
        // Reset to IDLE so the UI can start a new connection attempt.
        stateMachine.resetTo(CastSessionState.IDLE)
    }

    private val sessionListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarting(session: CastSession) {
            sessionRef.set(session)
            stateMachine.transitionTo(CastSessionState.CONNECTING)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            cancelConnectTimeout()
            sessionRef.set(session)
            errorHandler.onSessionReset()
            stateMachine.transitionTo(CastSessionState.CONNECTED)
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            cancelConnectTimeout()
            sessionRef.set(null)
            errorHandler.handle(
                CastError(CastErrorCode.SESSION_START_FAILED, "code=$error")
            )
            stateMachine.transitionTo(CastSessionState.ERROR)
            stateMachine.resetTo(CastSessionState.IDLE)
        }

        override fun onSessionResuming(session: CastSession, sessionId: String) {
            sessionRef.set(session)
            // Keep the suspended state until onSessionResumed transitions back to CONNECTED.
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            sessionRef.set(session)
            errorHandler.onSessionResumed()
            stateMachine.transitionTo(CastSessionState.CONNECTED)
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            sessionRef.set(null)
            errorHandler.handle(CastError(CastErrorCode.SESSION_SUSPENDED, "resume failed code=$error"))
            stateMachine.transitionTo(CastSessionState.DISCONNECTED)
        }

        override fun onSessionSuspended(session: CastSession, reason: Int) {
            // The receiver is temporarily unavailable. ErrorHandler handles the suspend timeout.
            stateMachine.transitionTo(CastSessionState.SUSPENDED)
            errorHandler.handle(
                CastError(CastErrorCode.SESSION_SUSPENDED, "suspended reason=$reason")
            )
        }

        override fun onSessionEnding(session: CastSession) {
            stateMachine.transitionTo(CastSessionState.ENDING)
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            cancelConnectTimeout()
            sessionRef.set(null)
            // Classify platform session-end codes.
            when (error) {
                0 -> {
                    // Normal exit, either initiated locally or completed by the receiver.
                    stateMachine.transitionTo(CastSessionState.DISCONNECTED)
                }
                else -> {
                    // Some platform codes may indicate that another sender took over the session.
                    // The SDK does not expose a fully stable distinction, so ambiguous cases are
                    // treated conservatively as receiver-ended sessions.
                    val code = if (reason(error) == ReasonKind.TAKEN_OVER) {
                        CastErrorCode.SESSION_TAKEN_OVER
                    } else {
                        CastErrorCode.SESSION_ENDED_BY_RECEIVER
                    }
                    errorHandler.handle(CastError(code, "session ended code=$error"))
                    stateMachine.transitionTo(CastSessionState.DISCONNECTED)
                }
            }
            deviceRef.set(null)
        }
    }

    private enum class ReasonKind { TAKEN_OVER, ENDED_BY_RECEIVER }
    private fun reason(code: Int): ReasonKind {
        // Some session end codes can indicate takeover, but the distinction is not
        // stable enough across scenarios, so unknown cases are handled conservatively.
        return when (code) {
            2002 -> ReasonKind.TAKEN_OVER
            else -> ReasonKind.ENDED_BY_RECEIVER
        }
    }
}
