// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastOptions
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.ICastController
import com.byteplus.vodcast.api.IDiscovery
import com.byteplus.vodcast.api.LoadOptions
import com.byteplus.vodcast.api.MediaItem
import com.byteplus.vodcast.api.RemoteMediaState
import com.byteplus.vodcast.core.Dispatchers
import com.byteplus.vodcast.core.ErrorHandler
import com.byteplus.vodcast.core.StateMachine
import com.google.android.gms.cast.MediaError
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.atomic.AtomicReference

/**
 * ChromeCast-backed [ICastController] implementation.
 *
 * All commands are serialized on [Dispatchers.castExecutor]. Progress callbacks are
 * emitted only while the session is in a stable playback state. Quality switching is
 * implemented as a reload that preserves the latest known playback position.
 */
internal class ChromecastController(
    private val sessionManager: ChromecastSessionManager,
    private val discovery: ChromecastDiscovery,
    private val stateMachine: StateMachine,
    private val errorHandler: ErrorHandler,
    private val options: CastOptions = CastSdk.options(),
) : ICastController {

    private val listeners = CopyOnWriteArrayList<ICastController.Listener>()
    private val deviceRef = AtomicReference<CastDevice?>(null)
    private val mediaRef = AtomicReference<MediaItem?>(null)
    private val remoteStateRef = AtomicReference(RemoteMediaState.IDLE)
    private val remoteClientRef = AtomicReference<RemoteMediaClient?>(null)
    private val lastLoadRef = AtomicReference<Pair<MediaItem, LoadOptions>?>(null)
    private val pendingLoadRef = AtomicReference<Pair<MediaItem, LoadOptions>?>(null)

    private val progressInterval: Long get() = options.progressIntervalMs

    init {
        // Forward state-machine updates to SDK listeners.
        stateMachine.addListener(StateMachine.Listener { _, to ->
            updateRemoteState { it.copy(state = to) }
            Dispatchers.postMain {
                listeners.forEach { runCatching { it.onStateChanged(to) } }
            }
            // Attach the remote media client when connected and release it on terminal states.
            when (to) {
                CastSessionState.CONNECTED -> {
                    attachRemoteMediaClient()
                    drainPendingLoad()
                }
                CastSessionState.DISCONNECTED, CastSessionState.IDLE, CastSessionState.ERROR -> {
                    pendingLoadRef.set(null)
                    detachRemoteMediaClient()
                }
                else -> Unit
            }
        })
        // Errors are forwarded to business listeners through ErrorHandler hooks.
    }

    override val state: CastSessionState get() = stateMachine.state

    override fun currentRemoteState(): RemoteMediaState = remoteStateRef.get()

    override fun discovery(): IDiscovery = discovery

    override fun connect(device: CastDevice) {
        Dispatchers.postCast {
            // Fallback: a new connection must always be able to start. If the state machine
            // is parked where it cannot legally reach CONNECTING (a terminal state from a
            // previous session, or a stale active state left by an abnormal teardown),
            // normalize to IDLE first so the connect flow is never silently dropped.
            val current = stateMachine.state
            if (current != CastSessionState.CONNECTING &&
                !StateMachine.isLegal(current, CastSessionState.CONNECTING)
            ) {
                stateMachine.resetTo(CastSessionState.IDLE)
            }
            deviceRef.set(device)
            updateRemoteState { it.copy(device = device) }
            Dispatchers.postMain {
                listeners.forEach { runCatching { it.onDeviceChanged(device) } }
            }
            sessionManager.connect(device)
        }
    }

    override fun disconnect(endSession: Boolean) {
        Dispatchers.postCast {
            sessionManager.disconnect(endSession)
        }
    }

    override fun load(item: MediaItem, options: LoadOptions) {
        Dispatchers.postCast {
            mediaRef.set(item)
            lastLoadRef.set(item to options)
            updateRemoteState {
                it.copy(
                    mediaItem = item,
                    durationMs = item.durationMs,
                    progressMs = options.playPositionMs.coerceAtLeast(0L),
                    playbackSpeed = options.speed,
                )
            }
            // The receiver session is established asynchronously. Sending the media before
            // CONNECTED means RemoteMediaClient is still null and the load is dropped, which
            // leaves the TV on the idle cast screen. Defer until CONNECTED unless the session
            // is already active (e.g. quality switch / replacing media while casting).
            if (stateMachine.state == CastSessionState.CONNECTED || stateMachine.state.isCasting) {
                stateMachine.transitionTo(CastSessionState.LOADING)
                sendLoad(item, options)
            } else {
                pendingLoadRef.set(item to options)
            }
        }
    }

    /** Sends a load request that was deferred until the session reached CONNECTED. */
    private fun drainPendingLoad() {
        val (item, opts) = pendingLoadRef.getAndSet(null) ?: return
        Dispatchers.postCast {
            stateMachine.transitionTo(CastSessionState.LOADING)
            sendLoad(item, opts)
        }
    }

    override fun switchQuality(item: MediaItem) {
        Dispatchers.postCast {
            // Preserve current progress and reuse the last known playback speed
            val current = remoteStateRef.get()
            val newOptions = LoadOptions(
                autoplay = true,
                playPositionMs = current.progressMs.coerceAtLeast(0L),
                speed = current.playbackSpeed.takeIf { it > 0f } ?: 1f,
            )
            load(item, newOptions)
        }
    }

    override fun play() {
        Dispatchers.postCast {
            runCatching { remoteClientRef.get()?.play() }
                .onFailure { errorHandler.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED, "play failed", cause = it)) }
        }
    }

    override fun pause() {
        Dispatchers.postCast {
            runCatching { remoteClientRef.get()?.pause() }
        }
    }

    override fun seekTo(positionMs: Long) {
        Dispatchers.postCast {
            runCatching { remoteClientRef.get()?.seek(positionMs) }
        }
    }

    override fun setSpeed(speed: Float) {
        Dispatchers.postCast {
            runCatching { remoteClientRef.get()?.setPlaybackRate(speed.toDouble()) }
            updateRemoteState { it.copy(playbackSpeed = speed) }
        }
    }

    override fun setVolume(volume: Float) {
        Dispatchers.postCast {
            runCatching { sessionManager.currentSession()?.volume = volume.toDouble() }
            updateRemoteState { it.copy(volume = volume) }
        }
    }

    override fun endSession() {
        disconnect(endSession = true)
    }

    override fun addListener(listener: ICastController.Listener) {
        listeners.addIfAbsent(listener)
    }

    override fun removeListener(listener: ICastController.Listener) {
        listeners.remove(listener)
    }

    // -- internal helpers -------------------------------------------------

    private fun attachRemoteMediaClient() {
        Dispatchers.postMain {
            val client = sessionManager.currentSession()?.remoteMediaClient ?: return@postMain
            val previous = remoteClientRef.getAndSet(client)
            if (previous === client) return@postMain
            previous?.let { detachClient(it) }
            client.registerCallback(remoteCallback)
            client.addProgressListener(progressListener, progressInterval)
        }
    }

    private fun detachRemoteMediaClient() {
        val client = remoteClientRef.getAndSet(null) ?: return
        Dispatchers.postMain { detachClient(client) }
    }

    private fun detachClient(client: RemoteMediaClient) {
        runCatching { client.unregisterCallback(remoteCallback) }
        runCatching { client.removeProgressListener(progressListener) }
    }

    private fun sendLoad(item: MediaItem, opts: LoadOptions) {
        Dispatchers.postMain {
            val client = remoteClientRef.get() ?: sessionManager.currentSession()?.remoteMediaClient
            if (client == null) {
                errorHandler.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED, "remote client null"))
                return@postMain
            }
            remoteClientRef.compareAndSet(null, client)
            val (info, loadOpts) = ChromecastMediaInfoMapper.adapt(item, opts)
            runCatching { client.load(info, loadOpts) }
                .onSuccess { pending ->
                    pending.setResultCallback { result ->
                        val status = result.status
                        if (!status.isSuccess) {
                            errorHandler.handle(
                                CastError(
                                    CastErrorCode.MEDIA_LOAD_FAILED,
                                    "load rejected code=${status.statusCode} msg=${status.statusMessage}"
                                )
                            )
                        }
                    }
                }
                .onFailure {
                    errorHandler.handle(
                        CastError(CastErrorCode.MEDIA_LOAD_FAILED, "load crashed", cause = it)
                    )
                }
        }
    }

    private fun updateRemoteState(transform: (RemoteMediaState) -> RemoteMediaState) {
        while (true) {
            val prev = remoteStateRef.get()
            val next = transform(prev).copy(updatedAtMs = System.currentTimeMillis())
            if (remoteStateRef.compareAndSet(prev, next)) return
        }
    }

    private val progressListener = RemoteMediaClient.ProgressListener { progressMs, durationMs ->
        if (!stateMachine.state.canEmitProgress) return@ProgressListener
        updateRemoteState { it.copy(progressMs = progressMs, durationMs = durationMs) }
        Dispatchers.postMain {
            listeners.forEach {
                runCatching { it.onProgressChanged(progressMs, durationMs) }
            }
        }
    }

    private val remoteCallback = object : RemoteMediaClient.Callback() {
        override fun onStatusUpdated() {
            val client = remoteClientRef.get() ?: return
            val mediaStatus = client.mediaStatus
            val playerState = mediaStatus?.playerState ?: return
            val target = when (playerState) {
                com.google.android.gms.cast.MediaStatus.PLAYER_STATE_PLAYING -> CastSessionState.PLAYING
                com.google.android.gms.cast.MediaStatus.PLAYER_STATE_PAUSED -> CastSessionState.PAUSED
                com.google.android.gms.cast.MediaStatus.PLAYER_STATE_BUFFERING -> CastSessionState.BUFFERING
                com.google.android.gms.cast.MediaStatus.PLAYER_STATE_LOADING -> CastSessionState.LOADING
                com.google.android.gms.cast.MediaStatus.PLAYER_STATE_IDLE -> {
                    // IDLE_REASON_ERROR after a load attempt means the receiver could not play the
                    // media (e.g. unreachable URL / unsupported format). Surface it instead of
                    // silently sitting on the cast idle screen.
                    if (mediaStatus.idleReason == com.google.android.gms.cast.MediaStatus.IDLE_REASON_ERROR) {
                        errorHandler.handle(
                            CastError(CastErrorCode.MEDIA_LOAD_FAILED, "receiver idle reason=ERROR")
                        )
                    }
                    // Only enter IDLE after the SDK state has already left the active session path.
                    if (stateMachine.state.isCasting) CastSessionState.CONNECTED else stateMachine.state
                }
                else -> stateMachine.state
            }
            stateMachine.transitionTo(target)
        }

        override fun onMediaError(error: MediaError) {
            errorHandler.handle(
                CastError(CastErrorCode.MEDIA_LOAD_FAILED, "media error: ${error.reason}")
            )
        }

        override fun onSendingRemoteMediaRequest() = Unit
        override fun onMetadataUpdated() = Unit
        override fun onPreloadStatusUpdated() = Unit
        override fun onQueueStatusUpdated() = Unit
    }

    /** Replays the most recent load request for retry scenarios. */
    internal fun retryLastLoad(): Boolean {
        val (item, opts) = lastLoadRef.get() ?: return false
        sendLoad(item, opts)
        return true
    }

    /** Forwards an SDK error to business listeners. Internal use only. */
    internal fun dispatchError(error: CastError) {
        Dispatchers.postMain {
            listeners.forEach { runCatching { it.onError(error) } }
        }
    }
}
