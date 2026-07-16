// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.stream

import android.net.Uri

enum class CustomStreamFormat {
    FLV,
    RTM,
    HLS,
    RTMPS,
}

data class CustomStreamUrl(
    val url: String,
    val format: CustomStreamFormat,
)

/**
 * Classifies a user-typed pull URL into one of the four supported protocols.
 *
 * Detection priority matters: RTMP/RTMPS are identified by the `rtmp://` /
 * `rtmps://` *scheme* (they carry no distinctive path extension), while RTM /
 * HLS / FLV are matched by their path extension (`.sdp` / `.m3u8` / `.flv`).
 * Anything else (e.g. a VOD `.mp4` / `.mov` address) is rejected so the UI can
 * prompt for a valid URL.
 */
object CustomStreamUrlParser {

    fun parse(input: String): CustomStreamUrl? {
        val url = input.trim()
        if (url.isEmpty()) return null
        val uri = runCatching { Uri.parse(url) }.getOrNull() ?: return null
        val scheme = uri.scheme?.lowercase().orEmpty()
        val path = uri.path.orEmpty()
        val format = when {
            scheme == "rtmp" || scheme == "rtmps" -> CustomStreamFormat.RTMPS
            path.endsWith(".m3u8", ignoreCase = true) -> CustomStreamFormat.HLS
            path.endsWith(".sdp", ignoreCase = true) -> CustomStreamFormat.RTM
            path.endsWith(".flv", ignoreCase = true) -> CustomStreamFormat.FLV
            else -> return null
        }
        return CustomStreamUrl(url, format)
    }
}
