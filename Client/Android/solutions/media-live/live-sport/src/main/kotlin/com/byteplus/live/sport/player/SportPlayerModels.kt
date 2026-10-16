// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.player

import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerResolution

/**
 * Top-level pull protocol strategy. These two are mutually exclusive choices on
 * the SAME dimension (which protocol to pull).
 *
 * IMPORTANT — dimension separation (see .localFiles/RTM规则):
 *  - [RTM_FIRST] / [FLV_ONLY] decide the *protocol*.
 *  - Low-latency FLV and ABR are *features that only exist inside FLV* — they
 *    live on [SportPlayerConfig], not here.
 *  - RTM is always a single stream: it has NO resolution-switch / ABR concept.
 *  - SR / Sharpen work on BOTH protocols.
 */
enum class PlayStrategy {
    /**
     * Best practice for sports streaming: pull the RTM stream first; when RTM
     * playback reports a fatal error, [SportLivePlayer] destroys the player and
     * rebuilds it to play the FLV stream instead.
     */
    RTM_FIRST,

    /** Pull the FLV stream directly; no protocol fallback involved. */
    FLV_ONLY,

    /**
     * Pull exactly one user-provided stream URL. The concrete format is carried
     * by [SportPlayerConfig.singleStream]; no protocol fallback or ABR applies.
     */
    SINGLE_STREAM,
}

/**
 * UI-facing pull-protocol option. The settings panel exposes the three
 * variants the product spec lists, but internally each variant maps onto the
 * underlying ([PlayStrategy], `enableLowLatencyFlv`) pair so the player layer
 * stays unchanged.
 *
 *  - [RTM] -> RTM_FIRST (with built-in FLV fallback on fatal RTM error).
 *  - [FLV_LOW_LATENCY] -> FLV_ONLY + low-latency FLV property.
 *  - [FLV_NORMAL] -> FLV_ONLY without low-latency.
 */
enum class PullProtocolOption {
    RTM,
    FLV_LOW_LATENCY,
    FLV_NORMAL;

    /** Underlying [PlayStrategy] this UI option drives. */
    val strategy: PlayStrategy
        get() = if (this == RTM) PlayStrategy.RTM_FIRST else PlayStrategy.FLV_ONLY

    /** Whether the FLV low-latency property should be enabled for this option. */
    val lowLatencyFlv: Boolean
        get() = this == FLV_LOW_LATENCY

    companion object {
        /** Map a player-layer state back to the user-visible option. */
        fun from(strategy: PlayStrategy, lowLatencyFlv: Boolean): PullProtocolOption =
            when (strategy) {
                PlayStrategy.RTM_FIRST -> RTM
                PlayStrategy.FLV_ONLY -> if (lowLatencyFlv) FLV_LOW_LATENCY else FLV_NORMAL
                PlayStrategy.SINGLE_STREAM -> if (lowLatencyFlv) FLV_LOW_LATENCY else FLV_NORMAL
            }
    }
}

/**
 * Resolution tier of an FLV stream. Maps 1:1 to the SDK's
 * [VeLivePlayerResolution] string constants so the UI never touches SDK types.
 */
enum class Resolution(val sdkValue: String) {
    ORIGIN(VeLivePlayerResolution.VeLivePlayerResolutionOrigin),
    UHD(VeLivePlayerResolution.VeLivePlayerResolutionUHD),
    HD(VeLivePlayerResolution.VeLivePlayerResolutionHD),
    SD(VeLivePlayerResolution.VeLivePlayerResolutionSD),
    LD(VeLivePlayerResolution.VeLivePlayerResolutionLD);

    companion object {
        /** Lenient parse from JSON / SDK string; defaults to [ORIGIN]. */
        fun from(value: String?): Resolution =
            entries.firstOrNull { it.name.equals(value, ignoreCase = true) }
                ?: entries.firstOrNull { it.sdkValue == value }
                ?: ORIGIN
    }
}

/**
 * A single FLV stream tier. Only FLV streams carry resolution/bitrate — RTM is
 * a single stream described by [SportPlayerConfig.rtmUrl].
 */
data class FlvStream(
    val resolution: Resolution,
    val bitrateKbps: Long,
    val url: String,
)

/**
 * Format of a user-provided single stream ([PlayStrategy.SINGLE_STREAM]).
 *
 * Playback is driven by [com.ss.videoarch.liveplayer.VeLivePlayer.setPlayUrl],
 * which auto-detects the protocol from the URL itself — so this enum does NOT
 * decide how the SDK pulls the stream. It only gates the FLV-only features
 * (low-latency FLV), which apply when and only when [FLV] is selected.
 */
enum class SingleStreamFormat {
    FLV,
    RTM,
    HLS,
    RTMPS,
}

data class SingleStream(
    val format: SingleStreamFormat,
    val url: String,
)

enum class SportRenderFillMode {
    ASPECT_FIT,
    ASPECT_FILL,
    FULL_FILL,
}

/**
 * Immutable player configuration. Build a new one and call
 * [SportLivePlayer.setConfig] before [SportLivePlayer.play].
 */
data class SportPlayerConfig(
    val strategy: PlayStrategy,
    /** Required (must end with `.sdp`) when [strategy] == [PlayStrategy.RTM_FIRST]. */
    val rtmUrl: String? = null,
    /** FLV tiers. Used by FLV_ONLY and as the RTM fallback target. */
    val flvStreams: List<FlvStream> = emptyList(),
    /** Single user-provided stream for [PlayStrategy.SINGLE_STREAM]. */
    val singleStream: SingleStream? = null,

    // ---- FLV-only features (ignored while RTM is playing) ----
    val enableLowLatencyFlv: Boolean = false,
    val enableABR: Boolean = false,
    val defaultResolution: Resolution? = null,

    // ---- Cross-protocol features (work on both RTM and FLV) ----
    val enableSR: Boolean = false,
    val enableSharpen: Boolean = false,
    val enableSei: Boolean = false,
) {
    /** True when ABR/resolution switching is even applicable to this config. */
    val supportsResolutionSwitch: Boolean
        get() = strategy == PlayStrategy.FLV_ONLY && flvStreams.size > 1
}

/**
 * Per-second playback statistics surfaced to the UI (delay / bitrate overlays).
 * Mirror of the fields we consume from `VeLivePlayerStatistics`.
 */
data class SportPlayerStats(
    val delayMs: Long,
    val bitrateKbps: Long,
    val fps: Float,
    /** Human-readable codec; `bytevc1` is normalised to `H.265`. */
    val videoCodec: String,
    val width: Int,
    val height: Int,
)
