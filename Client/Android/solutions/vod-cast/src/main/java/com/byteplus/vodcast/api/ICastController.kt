// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic remote playback control interface.
 *
 * Thread model:
 * - Command methods (load/play/pause/seekTo/...) can be called from any thread,
 *   internally dispatched to castExecutor;
 * - Listener callbacks are all on main thread (see dispatcher in [CastSdk.register] options).
 */
interface ICastController {

    /** Current session state. Thread-safe. */
    val state: CastSessionState

    /** Current remote playback snapshot. Thread-safe. */
    fun currentRemoteState(): RemoteMediaState

    /** Device discovery entry. */
    fun discovery(): IDiscovery

    // -- session ----------------------------------------------------------

    /** Connect to device. Triggers `CONNECTING → CONNECTED`, timeout after 10s results in ERROR. */
    fun connect(device: CastDevice)

    /**
     * Disconnect.
     * @param endSession true to call platform SDK's endSession (release receiver);
     *                   false to only detach locally.
     */
    fun disconnect(endSession: Boolean = true)

    // -- media -----------------------------------------------------------

    /** Load media for casting. The caller provides the desired start position. */
    fun load(item: MediaItem, options: LoadOptions = LoadOptions())

    /** Switch quality by triggering a remote reload internally. */
    fun switchQuality(item: MediaItem)

    fun play()
    fun pause()
    fun seekTo(positionMs: Long)
    fun setSpeed(speed: Float)
    fun setVolume(volume: Float)

    /** End receiver session immediately. Equivalent to `disconnect(endSession = true)`. */
    fun endSession()

    // -- listener --------------------------------------------------------

    fun addListener(listener: Listener)
    fun removeListener(listener: Listener)

    interface Listener {
        /** Main thread. */
        fun onStateChanged(state: CastSessionState) {}
        /** Main thread. Only triggered when [CastSessionState.canEmitProgress] is true. */
        fun onProgressChanged(progressMs: Long, durationMs: Long) {}
        /** Main thread. All SDK errors are passed here. */
        fun onError(error: CastError) {}
        /** Main thread. Current selected device changed. */
        fun onDeviceChanged(device: CastDevice?) {}
    }
}
