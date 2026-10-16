// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.compare

import android.content.Context
import android.util.Log
import com.byteplus.live.sport.player.FlvStream
import com.byteplus.live.sport.player.PlayStrategy
import com.byteplus.live.sport.player.Resolution
import com.byteplus.live.sport.player.SingleStream
import com.byteplus.live.sport.player.SingleStreamFormat
import com.byteplus.live.sport.player.SportPlayerConfig
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

/**
 * Pull protocol shown in the Low-latency tab's per-card L3 selector.
 *
 * All five map onto a single playback URL handed to
 * [com.ss.videoarch.liveplayer.VeLivePlayer.setPlayUrl], which auto-detects the
 * concrete protocol from the address. [reserved] stays as a capability flag for
 * any protocol the demo wants to show but not play yet (currently none).
 */
enum class CompareProtocol(val reserved: Boolean) {
    RTM(false),
    FLV_LOW_LATENCY(false),
    FLV(false),
    HLS(false),
    RTMPS(false);

    companion object {
        fun from(value: String?): CompareProtocol =
            entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: FLV
    }
}

/**
 * One protocol entry on the Low-latency tab. Each protocol carries exactly the
 * single URL it needs ([rtmUrl] / [flvUrl] / [hlsUrl] / [rtmpsUrl]); the FLV URL
 * backs both FLV variants.
 */
data class CompareLatencyStream(
    val protocol: CompareProtocol,
    val rtmUrl: String?,
    val flvUrl: String?,
    val hlsUrl: String?,
    val rtmpsUrl: String?,
) {
    /**
     * Build the single-address player config for this entry, or null when the
     * protocol is reserved / has no usable URL.
     *
     * Every protocol plays through [PlayStrategy.SINGLE_STREAM] (i.e.
     * `setPlayUrl`); RTM here is a pure single stream with NO FLV fallback, so
     * the displayed latency reflects the protocol honestly. The format only
     * gates low-latency FLV — the SDK still detects the real protocol by URL.
     */
    fun toPlayerConfig(): SportPlayerConfig? {
        if (protocol.reserved) return null
        val (url, format, lowLatency) = when (protocol) {
            CompareProtocol.RTM -> Triple(rtmUrl, SingleStreamFormat.RTM, false)
            CompareProtocol.FLV_LOW_LATENCY -> Triple(flvUrl, SingleStreamFormat.FLV, true)
            CompareProtocol.FLV -> Triple(flvUrl, SingleStreamFormat.FLV, false)
            CompareProtocol.HLS -> Triple(hlsUrl, SingleStreamFormat.HLS, false)
            CompareProtocol.RTMPS -> Triple(rtmpsUrl, SingleStreamFormat.RTMPS, false)
        }
        val playUrl = url ?: return null
        return SportPlayerConfig(
            strategy = PlayStrategy.SINGLE_STREAM,
            singleStream = SingleStream(format = format, url = playUrl),
            enableLowLatencyFlv = lowLatency,
        )
    }
}

/** A single-address stream used by the Enhancement / Cost tabs. */
data class CompareSingleStream(val flvUrl: String?) {
    fun toPlayerConfig(enableSR: Boolean = false, enableSharpen: Boolean = false): SportPlayerConfig? {
        val flv = flvUrl ?: return null
        return SportPlayerConfig(
            strategy = PlayStrategy.FLV_ONLY,
            flvStreams = listOf(FlvStream(Resolution.ORIGIN, 0, flv)),
            enableSR = enableSR,
            enableSharpen = enableSharpen,
        )
    }
}

/** A H.265 vs H.264 pair, used by each Cost-reduction sub-tab. */
data class CompareCodecPair(
    val h265: CompareSingleStream,
    val h264: CompareSingleStream,
)

/** Whole comparison-page configuration parsed from `assets/live_sport_compare.json`. */
data class CompareConfig(
    val docUrlLatency: String?,
    val docUrlEnhance: String?,
    val docUrlCost: String?,
    val latency: List<CompareLatencyStream>,
    val enhance: CompareSingleStream,
    val costSameQuality: CompareCodecPair,
    val costSameBitrate: CompareCodecPair,
)

/** Loads [CompareConfig] from assets. Returns null on any IO/parse error. */
object CompareConfigRepo {

    private const val TAG = "CompareConfigRepo"
    private const val ASSET_NAME = "live_sport_compare.json"

    private data class RootDto(
        @SerializedName("doc_url_latency") val docUrlLatency: String? = null,
        @SerializedName("doc_url_enhance") val docUrlEnhance: String? = null,
        @SerializedName("doc_url_cost") val docUrlCost: String? = null,
        @SerializedName("latency") val latency: List<LatencyDto>? = null,
        @SerializedName("enhance") val enhance: SingleDto? = null,
        @SerializedName("cost") val cost: CostDto? = null,
    )

    private data class LatencyDto(
        @SerializedName("protocol") val protocol: String? = null,
        @SerializedName("rtm_url") val rtmUrl: String? = null,
        @SerializedName("flv_url") val flvUrl: String? = null,
        @SerializedName("hls_url") val hlsUrl: String? = null,
        @SerializedName("rtmps_url") val rtmpsUrl: String? = null,
    )

    private data class SingleDto(@SerializedName("flv_url") val flvUrl: String? = null)

    private data class CostDto(
        @SerializedName("same_quality") val sameQuality: PairDto? = null,
        @SerializedName("same_bitrate") val sameBitrate: PairDto? = null,
    )

    private data class PairDto(
        @SerializedName("h265_url") val h265Url: String? = null,
        @SerializedName("h264_url") val h264Url: String? = null,
    )

    fun load(context: Context): CompareConfig? {
        val json = runCatching {
            context.assets.open(ASSET_NAME).bufferedReader().use { it.readText() }
        }.getOrElse {
            Log.e(TAG, "Failed to read $ASSET_NAME", it)
            return null
        }

        val dto = runCatching {
            Gson().fromJson(json, RootDto::class.java)
        }.getOrElse {
            Log.e(TAG, "Failed to parse $ASSET_NAME", it)
            return null
        } ?: return null

        val latency = dto.latency.orEmpty().map { entry ->
            CompareLatencyStream(
                protocol = CompareProtocol.from(entry.protocol),
                rtmUrl = entry.rtmUrl,
                flvUrl = entry.flvUrl,
                hlsUrl = entry.hlsUrl,
                rtmpsUrl = entry.rtmpsUrl,
            )
        }
        return CompareConfig(
            docUrlLatency = dto.docUrlLatency,
            docUrlEnhance = dto.docUrlEnhance,
            docUrlCost = dto.docUrlCost,
            latency = latency,
            enhance = CompareSingleStream(dto.enhance?.flvUrl),
            costSameQuality = dto.cost?.sameQuality.toPair(),
            costSameBitrate = dto.cost?.sameBitrate.toPair(),
        )
    }

    private fun PairDto?.toPair(): CompareCodecPair = CompareCodecPair(
        h265 = CompareSingleStream(this?.h265Url),
        h264 = CompareSingleStream(this?.h264Url),
    )
}
