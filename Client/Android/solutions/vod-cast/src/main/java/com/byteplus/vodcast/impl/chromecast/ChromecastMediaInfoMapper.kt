// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.LoadOptions
import com.byteplus.vodcast.api.LocalPlayerHook
import com.byteplus.vodcast.api.MediaItem
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadOptions
import com.google.android.gms.cast.MediaMetadata as CastMediaMetadata
import com.google.android.gms.common.images.WebImage
import android.net.Uri

/**
 * Maps protocol-agnostic [MediaItem] to ChromeCast `MediaInfo + MediaLoadOptions` (T-Impl-MediaInfoMapper).
 *
 * Key strategies:
 * - `startPosition` is passed by the caller in [MediaItem.startPositionMs] / [LoadOptions.playPositionMs];
 *   if [com.byteplus.vodcast.api.LocalPlayerHook.isLocalCompleted] is true,
 *   force `progress=0` and `autoplay=true`;
 * - `speed` priority: [LoadOptions.speed] > [MediaItem.speed] > hook's current local speed;
 * - `metadata` writes title / cover / duration, visible on ChromeCast UI.
 */
internal object ChromecastMediaInfoMapper {

    fun adapt(item: MediaItem, options: LoadOptions = LoadOptions()): Pair<MediaInfo, MediaLoadOptions> {
        val resolved = resolveLoadParams(item, options, CastSdk.localPlayerHook())

        val metadataType = when (item.streamType) {
            MediaItem.StreamType.LIVE -> CastMediaMetadata.MEDIA_TYPE_GENERIC
            else -> CastMediaMetadata.MEDIA_TYPE_MOVIE
        }
        val metadata = CastMediaMetadata(metadataType).apply {
            item.metadata.title?.takeIf { it.isNotEmpty() }?.let {
                putString(CastMediaMetadata.KEY_TITLE, it)
            }
            item.metadata.subtitle?.takeIf { it.isNotEmpty() }?.let {
                putString(CastMediaMetadata.KEY_SUBTITLE, it)
            }
            item.metadata.coverUrl?.takeIf { it.isNotEmpty() }?.let { url ->
                runCatching { addImage(WebImage(Uri.parse(url))) }
            }
        }

        val streamType = when (item.streamType) {
            MediaItem.StreamType.LIVE -> MediaInfo.STREAM_TYPE_LIVE
            MediaItem.StreamType.BUFFERED -> MediaInfo.STREAM_TYPE_BUFFERED
            MediaItem.StreamType.NONE -> MediaInfo.STREAM_TYPE_NONE
        }

        val mediaInfo = MediaInfo.Builder(item.contentUrl)
            .setStreamType(streamType)
            .setContentType(item.contentType ?: "video/mp4")
            .setMetadata(metadata)
            .apply {
                if (item.durationMs > 0L) setStreamDuration(item.durationMs)
            }
            .build()

        val loadOptions = MediaLoadOptions.Builder()
            .setAutoplay(resolved.autoplay)
            .setPlayPosition(resolved.positionMs)
            .setPlaybackRate(resolved.speed.toDouble())
            .build()

        return mediaInfo to loadOptions
    }
}

/**
 * Resolved load parameters; pure Kotlin data class for unit testing load priority strategies.
 */
internal data class ResolvedLoadParams(
    val positionMs: Long,
    val autoplay: Boolean,
    val speed: Float,
)

/**
 * Calculate final playback position / autoplay / speed. Priority:
 *
 * - position: hook.isLocalCompleted=true → 0; else options.playPositionMs > 0 → use it;
 *             else item.startPositionMs > 0 → use it; else 0
 * - autoplay: hook.isLocalCompleted=true → true; else options.autoplay && item.autoplay
 * - speed: options.speed > 0 && != 1 → use it; else item.speed > 0 && != 1 → use it;
 *          else hook.currentLocalSpeed() ?: 1f
 */
internal fun resolveLoadParams(
    item: MediaItem,
    options: LoadOptions,
    hook: LocalPlayerHook?,
): ResolvedLoadParams {
    val isLocalCompleted = hook?.isLocalCompleted() == true

    val positionMs = when {
        isLocalCompleted -> 0L
        options.playPositionMs > 0L -> options.playPositionMs
        item.startPositionMs > 0L -> item.startPositionMs
        else -> 0L
    }

    val autoplay = when {
        isLocalCompleted -> true
        else -> options.autoplay && item.autoplay
    }

    val speed = when {
        options.speed > 0f && options.speed != 1f -> options.speed
        item.speed > 0f && item.speed != 1f -> item.speed
        else -> hook?.currentLocalSpeed()?.takeIf { it > 0f } ?: 1f
    }

    return ResolvedLoadParams(positionMs, autoplay, speed)
}
