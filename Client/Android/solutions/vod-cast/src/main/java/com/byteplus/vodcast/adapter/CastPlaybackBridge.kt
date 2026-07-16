// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.adapter

import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.CastSessionState.CONNECTED
import com.byteplus.vodcast.api.CastSessionState.DISCONNECTED
import com.byteplus.vodcast.api.CastSessionState.IDLE
import com.byteplus.vodcast.api.ICastController

/**
 * Bridge between casting session state and local player control.
 *
 * Automatically pauses local playback when entering casting (CONNECTED) and
 * resumes local playback with last remote progress when exiting (DISCONNECTED).
 *
 */
class CastPlaybackBridge(
    private val controller: ICastController,
) {

    @Volatile
    private var attached = false
    @Volatile
    private var localPlaybackPaused = false
    @Volatile
    private var lastRemoteProgressMs = 0L

    private val listener = object : ICastController.Listener {
        override fun onStateChanged(state: CastSessionState) {
            when (state) {
                CONNECTED -> handleConnected()
                DISCONNECTED, IDLE -> handleDisconnected()
                else -> {
                    // Track progress only when casting
                    if (state.isCasting) {
                        // Progress is tracked via onProgressChanged
                    }
                }
            }
        }

        override fun onProgressChanged(progressMs: Long, durationMs: Long) {
            lastRemoteProgressMs = progressMs
        }
    }

    fun attach() {
        if (!attached) {
            controller.addListener(listener)
            attached = true
        }
    }

    fun detach() {
        if (attached) {
            controller.removeListener(listener)
            attached = false
            // Ensure local playback is resumed if we were controlling it
            if (localPlaybackPaused) {
                CastSdk.localPlayerHook()?.resumeLocalPlayback(lastRemoteProgressMs)
                localPlaybackPaused = false
            }
        }
    }

    private fun handleConnected() {
        if (!localPlaybackPaused) {
            CastSdk.localPlayerHook()?.pauseLocalPlayback()
            localPlaybackPaused = true
        }
    }

    private fun handleDisconnected() {
        if (localPlaybackPaused) {
            CastSdk.localPlayerHook()?.resumeLocalPlayback(lastRemoteProgressMs)
            localPlaybackPaused = false
            // Reset progress to avoid polluting next session
            lastRemoteProgressMs = 0L
        }
    }
}
