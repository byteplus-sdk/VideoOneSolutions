// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic media item.
 *
 * Business layer or `MediaSourceAdapter` converts TTVideoEngine's `MediaSource` to this class,
 * then passes to `IRemotePlayerControl.load(...)` for casting.
 *
 * Key playback fields:
 * - `startPositionMs`: preferred initial playback position on the receiver
 * - `autoplay`: whether remote playback should start automatically
 * - `metadata`: title, subtitle, and cover shown on the receiver UI
 */
data class MediaItem(
    val contentUrl: String,
    val contentType: String? = null,
    val streamType: StreamType = StreamType.BUFFERED,
    val metadata: MediaMetadata = MediaMetadata.EMPTY,
    val startPositionMs: Long = 0L,
    val durationMs: Long = 0L,
    val speed: Float = 1f,
    val autoplay: Boolean = true,
    /** Quality identifier passed by business when switching quality. */
    val qualityTag: String? = null,
    val extras: Map<String, Any> = emptyMap(),
) {
    enum class StreamType { BUFFERED, LIVE, NONE }
}

/** Media metadata, corresponds to ChromeCast `MediaMetadata`. */
data class MediaMetadata(
    val title: String? = null,
    val subtitle: String? = null,
    val coverUrl: String? = null,
) {
    companion object {
        val EMPTY = MediaMetadata()
    }
}

/** Optional options during load. */
data class LoadOptions(
    val autoplay: Boolean = true,
    val playPositionMs: Long = 0L,
    val speed: Float = 1f,
)
