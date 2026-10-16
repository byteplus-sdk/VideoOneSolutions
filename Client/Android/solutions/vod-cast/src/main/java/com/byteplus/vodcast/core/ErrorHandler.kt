// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastOptions

/**
 * Error handling and recovery orchestrator.
 *
 * Handles all [CastErrorCode] types with appropriate recovery strategies:
 * - SESSION_START_FAILED: Emit only (connection already retried internally)
 * - SESSION_SUSPENDED: Schedule force disconnect after timeout, cancel on resume
 * - SESSION_TAKEN_OVER: Toast + emit (non-recoverable)
 * - SESSION_ENDED_BY_RECEIVER: Toast + emit (non-recoverable)
 * - MEDIA_LOAD_FAILED: Auto-retry up to [CastOptions.mediaLoadRetry] times
 * - NETWORK_LOST: Wait for network recovery, then trigger reconnect
 * - NO_NETWORK: Toast + emit (UI preflight should prevent this)
 * - DEVICE_UNAVAILABLE: Emit only (non-recoverable)
 */
class ErrorHandler(
    private val hooks: Hooks,
    private val options: CastOptions,
) {

    @Volatile
    private var mediaLoadRetryCount = 0
    @Volatile
    private var mediaLoadFailureHandled = false
    @Volatile
    private var suspendedCancellable: Cancellable? = null

    fun handle(error: CastError) {
        // MEDIA_LOAD_FAILED can be reported repeatedly (e.g. the receiver keeps emitting
        // IDLE_REASON_ERROR while it sits on the idle screen). Collapse the storm into a
        // single retry budget + one user-facing notification, then end the session so the
        // TV does not stay stuck and the user is not spammed with toasts.
        if (error.code == CastErrorCode.MEDIA_LOAD_FAILED) {
            handleMediaLoadFailed(error)
            return
        }

        hooks.emit(error)

        when (error.code) {
            CastErrorCode.SESSION_SUSPENDED -> {
                // Schedule a forced disconnect if the session does not resume in time
                suspendedCancellable = hooks.scheduleDelayed(options.suspendedTimeoutMs) {
                    hooks.forceDisconnect()
                }
            }

            CastErrorCode.SESSION_TAKEN_OVER -> {
                // Notify the user when the session is taken over by another sender
                hooks.showToast(error)
            }

            CastErrorCode.SESSION_ENDED_BY_RECEIVER -> {
                // Notify the user when the receiver ends the session
                hooks.showToast(error)
            }

            CastErrorCode.NO_NETWORK -> {
                // Surface the no-network case to the UI immediately
                hooks.showToast(error)
            }

            else -> {
                // SESSION_START_FAILED, NETWORK_LOST, DEVICE_UNAVAILABLE: just emit
            }
        }
    }

    private fun handleMediaLoadFailed(error: CastError) {
        // Already gave up on this media; ignore the repeated failures until the session resets.
        if (mediaLoadFailureHandled) return

        if (mediaLoadRetryCount < options.mediaLoadRetry) {
            mediaLoadRetryCount++
            hooks.retryMediaLoad()
            return
        }

        // Retry budget exhausted: notify the user once, end the receiver session so the TV
        // leaves the idle cast screen, and stop reacting to further load failures.
        mediaLoadFailureHandled = true
        hooks.emit(error)
        hooks.showToast(error)
        hooks.forceDisconnect()
    }

    fun onSessionResumed() {
        // Cancel pending suspended timeout
        suspendedCancellable?.cancel()
        suspendedCancellable = null
    }

    fun onNetworkRestored() {
        hooks.tryReconnect()
    }

    fun onSessionReset() {
        // Reset retry counters when session is reset
        mediaLoadRetryCount = 0
        mediaLoadFailureHandled = false
    }

    interface Hooks {
        fun emit(error: CastError)
        fun showToast(error: CastError)
        fun retryMediaLoad(): Boolean
        fun tryReconnect()
        fun forceDisconnect()
        fun scheduleDelayed(delayMs: Long, action: () -> Unit): Cancellable
    }

    interface Cancellable {
        fun cancel()
    }
}
