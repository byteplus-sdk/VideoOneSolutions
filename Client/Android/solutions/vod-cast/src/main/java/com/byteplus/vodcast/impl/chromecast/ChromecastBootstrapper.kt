// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import android.content.Context
import com.byteplus.vodcast.adapter.CastPlaybackBridge
import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.ICastController
import com.byteplus.vodcast.core.Dispatchers
import com.byteplus.vodcast.core.ErrorHandler
import com.byteplus.vodcast.core.NetworkMonitor
import com.byteplus.vodcast.core.StateMachine
import android.os.Handler
import android.os.Looper

/**
 * ChromeCast implementation bootstrap entry.
 *
 * Called by [CastSdk.register]: constructs StateMachine / ErrorHandler / NetworkMonitor /
 * Discovery / SessionManager / Controller / PlaybackBridge, and injects controller back to [CastSdk].
 *
 * Idempotent within same process: first call wins.
 */
internal object ChromecastBootstrapper {

    @Volatile private var booted: Boolean = false
    @Volatile private var controller: ChromecastController? = null

    @Synchronized
    fun boot(context: Context): ICastController {
        controller?.let { return it }

        val app = context.applicationContext
        val stateMachine = StateMachine()
        val mainHandler = Handler(Looper.getMainLooper())

        // ErrorHandler hooks are temporarily placeholders, will be filled after controller construction
        var ctrlRef: ChromecastController? = null
        var sessionRef: ChromecastSessionManager? = null
        val errorHandler = ErrorHandler(
            hooks = object : ErrorHandler.Hooks {
                override fun emit(error: CastError) {
                    // Pass through to business listener
                    Dispatchers.postMain {
                        ctrlRef?.dispatchError(error)
                    }
                }

                override fun showToast(error: CastError) {
                    // Default no-op; UI layer can subscribe to onError for toast
                }

                override fun retryMediaLoad(): Boolean = ctrlRef?.retryLastLoad() == true

                override fun tryReconnect() {
                    val device = sessionRef?.currentDevice() ?: return
                    ctrlRef?.connect(device)
                }

                override fun forceDisconnect() {
                    sessionRef?.disconnect(endSession = true)
                }

                override fun scheduleDelayed(
                    delayMs: Long,
                    action: () -> Unit
                ): ErrorHandler.Cancellable {
                    val r = Runnable { action() }
                    mainHandler.postDelayed(r, delayMs)
                    return object : ErrorHandler.Cancellable {
                        override fun cancel() {
                            mainHandler.removeCallbacks(r)
                        }
                    }
                }
            },
            options = CastSdk.options(),
        )

        val discovery = ChromecastDiscovery(app)
        val sessionManager = ChromecastSessionManager(
            context = app,
            stateMachine = stateMachine,
            errorHandler = errorHandler,
            discovery = discovery,
        )
        sessionRef = sessionManager

        val ctrl = ChromecastController(
            sessionManager = sessionManager,
            discovery = discovery,
            stateMachine = stateMachine,
            errorHandler = errorHandler,
        )
        ctrlRef = ctrl
        controller = ctrl

        // Attach PlaybackBridge
        CastPlaybackBridge(ctrl).attach()

        // NetworkMonitor -> ErrorHandler network recovery callback
        val networkMonitor = NetworkMonitor(app)
        networkMonitor.addListener(object : NetworkMonitor.Listener {
            override fun onNetworkRestored() {
                errorHandler.onNetworkRestored()
                // Rebuild the device list: routes discovered before the network dropped
                // may be stale, and a list initialized while offline can be empty.
                if (discovery.isScanning) {
                    discovery.refresh()
                } else {
                    discovery.start()
                }
            }

            override fun onNetworkLost() {
                if (stateMachine.state.isCasting) {
                    errorHandler.handle(
                        CastError(CastErrorCode.NETWORK_LOST, "network lost")
                    )
                }
            }
        })
        networkMonitor.start()

        sessionManager.start()
        CastSdk.installImpl(ctrl)

        booted = true
        return ctrl
    }
}
