// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.data

import com.byteplus.live.sport.player.FlvStream
import com.byteplus.live.sport.player.PlayStrategy
import com.byteplus.live.sport.player.PullProtocolOption
import com.byteplus.live.sport.player.Resolution
import com.byteplus.live.sport.player.SportPlayerConfig

/**
 * A sports channel (one "camera" entry in the horizontal switcher), parsed from
 * `assets/live_sport_channels.json`.
 *
 * Field separation follows the protocol-vs-feature dimension split:
 *  - [strategy] picks the *initial* protocol (RTM_FIRST or FLV_ONLY).
 *  - [rtmUrl] is the single RTM stream; if null the channel does not support
 *    RTM at all and the settings panel disables the RTM option.
 *  - [flvStreams] holds FLV tiers only; for RTM_FIRST it is the fallback target.
 *  - [lowLatencyFlv] / [abr] are FLV-only features. They reflect the channel's
 *    *initial* preference; the user can flip them at runtime.
 */
data class SportChannel(
    val id: String,
    val name: String,
    val strategy: PlayStrategy,
    val rtmUrl: String?,
    val lowLatencyFlv: Boolean,
    val abr: Boolean,
    val flvStreams: List<FlvStream>,
) {
    /** True when this channel exposes more than one FLV tier (so switching/ABR is meaningful). */
    val hasMultipleTiers: Boolean get() = flvStreams.size > 1

    /** True when the channel carries a usable RTM URL, i.e. the RTM option may be selected. */
    val rtmSupported: Boolean get() = !rtmUrl.isNullOrEmpty()

    /**
     * Build the player config for this channel.
     *
     * @param protocol the user-chosen pull protocol option; mapped onto
     *        [PlayStrategy] + low-latency-FLV under the hood. If the channel
     *        doesn't support RTM, callers MUST pass an FLV variant — this
     *        function does not silently downgrade.
     * @param abrAuto true = ABR auto-switch on (only effective on multi-tier
     *        FLV); false = a fixed tier pinned by [pinnedResolution].
     * @param pinnedResolution the tier to start on when [abrAuto] is false;
     *        ignored when [abrAuto] is true. Defaults to the first declared tier.
     * @param enableSR initial super-resolution state.
     * @param enableSharpen initial sharpen state.
     */
    fun toPlayerConfig(
        protocol: PullProtocolOption,
        abrAuto: Boolean,
        pinnedResolution: Resolution?,
        enableSR: Boolean,
        enableSharpen: Boolean,
    ): SportPlayerConfig =
        SportPlayerConfig(
            strategy = protocol.strategy,
            rtmUrl = rtmUrl,
            flvStreams = flvStreams,
            // ABR auto-switch only makes sense with more than one FLV tier.
            enableABR = abrAuto && hasMultipleTiers,
            enableLowLatencyFlv = protocol.lowLatencyFlv,
            // Auto → start on the first tier and let the algorithm take over;
            // manual → pin the chosen tier.
            defaultResolution = pinnedResolution
                ?: flvStreams.firstOrNull()?.resolution
                ?: Resolution.ORIGIN,
            enableSR = enableSR,
            enableSharpen = enableSharpen,
        )
}
