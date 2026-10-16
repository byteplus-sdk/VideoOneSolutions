// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.data

import android.content.Context
import android.util.Log
import com.byteplus.live.sport.player.FlvStream
import com.byteplus.live.sport.player.PlayStrategy
import com.byteplus.live.sport.player.Resolution
import com.google.gson.annotations.SerializedName
import com.google.gson.Gson

/**
 * Loads the channel list from `assets/live_sport_channels.json`.
 *
 * Data-driven by design: render as many cameras as the JSON declares — the UI
 * adapts (see TECH_DESIGN §5.1). Stream URLs are placeholders until the backend
 * provides real sports streams.
 */
object SportChannelRepo {

    private const val TAG = "SportChannelRepo"
    private const val ASSET_NAME = "live_sport_channels.json"

    /** Gson DTO mirroring the JSON; mapped to the domain [SportChannel] below. */
    private data class ChannelDto(
        @SerializedName("id") val id: String? = null,
        @SerializedName("name") val name: String? = null,
        @SerializedName("strategy") val strategy: String? = null,
        @SerializedName("rtm_url") val rtmUrl: String? = null,
        @SerializedName("low_latency_flv") val lowLatencyFlv: Boolean = false,
        @SerializedName("abr") val abr: Boolean = false,
        @SerializedName("flv_streams") val flvStreams: List<StreamDto>? = null,
    )

    private data class StreamDto(
        @SerializedName("resolution") val resolution: String? = null,
        @SerializedName("bitrate") val bitrate: Long = 0,
        @SerializedName("url") val url: String? = null,
    )

    /**
     * Parse the asset into channels. Returns an empty list on any IO/parse error
     * (the caller decides how to surface that); malformed individual entries are
     * skipped rather than failing the whole list.
     */
    fun load(context: Context): List<SportChannel> {
        val json = runCatching {
            context.assets.open(ASSET_NAME).bufferedReader().use { it.readText() }
        }.getOrElse {
            Log.e(TAG, "Failed to read $ASSET_NAME", it)
            return emptyList()
        }

        val dtos = runCatching {
            Gson().fromJson(json, Array<ChannelDto>::class.java)
        }.getOrElse {
            Log.e(TAG, "Failed to parse $ASSET_NAME", it)
            return emptyList()
        } ?: return emptyList()

        return dtos.mapNotNull { it.toChannelOrNull(context) }
    }

    private fun ChannelDto.toChannelOrNull(context: Context): SportChannel? {
        val id = id ?: return null
        val name = localizedName(context, id) ?: name ?: id
        val strategy = runCatching { PlayStrategy.valueOf(strategy.orEmpty()) }
            .getOrDefault(PlayStrategy.FLV_ONLY)

        val streams = flvStreams.orEmpty().mapNotNull { dto ->
            val url = dto.url ?: return@mapNotNull null
            FlvStream(
                resolution = Resolution.from(dto.resolution),
                bitrateKbps = dto.bitrate,
                url = url,
            )
        }

        // RTM_FIRST needs an rtmUrl; FLV_ONLY needs at least one FLV tier.
        if (strategy == PlayStrategy.RTM_FIRST && rtmUrl.isNullOrEmpty()) {
            Log.w(TAG, "Channel $id is RTM_FIRST but has no rtm_url; skipping")
            return null
        }
        if (streams.isEmpty()) {
            Log.w(TAG, "Channel $id has no flv_streams; skipping")
            return null
        }

        return SportChannel(
            id = id,
            name = name,
            strategy = strategy,
            rtmUrl = rtmUrl,
            lowLatencyFlv = lowLatencyFlv,
            abr = abr,
            flvStreams = streams,
        )
    }

    /**
     * Resolve a localized channel name from `live_sport_camera_name_<id>` so the
     * multi-camera switcher shows the right language. Returns null when no such
     * string exists, letting the caller fall back to the JSON `name`.
     */
    private fun localizedName(context: Context, id: String): String? {
        val resId = context.resources.getIdentifier(
            "live_sport_camera_name_${id.lowercase()}",
            "string",
            context.packageName,
        )
        return if (resId != 0) context.getString(resId) else null
    }
}
