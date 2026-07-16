// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic remote playback snapshot. All fields are maintained by the SDK and are read-only to business code.
 */
data class RemoteMediaState(
    val state: CastSessionState = CastSessionState.IDLE,
    val mediaItem: MediaItem? = null,
    val device: CastDevice? = null,
    val progressMs: Long = 0L,
    val durationMs: Long = 0L,
    val playbackSpeed: Float = 1f,
    val volume: Float = 1f,
    val muted: Boolean = false,
    val updatedAtMs: Long = System.currentTimeMillis(),
) {
    companion object {
        val IDLE = RemoteMediaState()
    }
}
