// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.compare

import android.content.Context
import android.view.TextureView
import com.byteplus.live.sport.player.SportLivePlayer
import com.byteplus.live.sport.player.SportPlayerConfig
import com.byteplus.live.sport.player.SportPlayerStats

/**
 * One independent player area on the comparison page: owns a [SportLivePlayer]
 * bound to a [TextureView], tracks user playback/mute intent, and keeps a rolling
 * bitrate history for the waveform dialog.
 *
 * Players are recreated per [SportLivePlayer] contract (inert after destroy):
 * [release] tears the current one down; [bind] builds a fresh one.
 */
class CompareSlot(
    private val context: Context,
    val texture: TextureView,
) {
    private var player: SportLivePlayer? = null
    private var config: SportPlayerConfig? = null

    /** Per-tick callbacks for the host to update overlays / live charts. */
    var onStats: ((SportPlayerStats) -> Unit)? = null

    /** Last ~60 bitrate samples (kbps), oldest first. */
    private val bitrateHistory = ArrayDeque<Long>(BITRATE_CAPACITY)

    /** Whether this slot currently has a playable config (false for reserved protocols). */
    val hasStream: Boolean get() = config != null

    fun bitrateHistory(): List<Long> = bitrateHistory.toList()

    private val listener = object : SportLivePlayer.Listener {
        override fun onStats(stats: SportPlayerStats) {
            if (bitrateHistory.size >= BITRATE_CAPACITY) bitrateHistory.removeFirst()
            bitrateHistory.addLast(stats.bitrateKbps)
            onStats?.invoke(stats)
        }
    }

    /**
     * Point this slot at [newConfig] and (re)build the player. A null config
     * means "no playable stream" (reserved protocol) — the slot is released and
     * left idle. Each new bind defaults to playing when visible and muted.
     */
    var isPlaying: Boolean = false
        private set

    var isMuted: Boolean = true
        private set

    private var userPaused = false

    fun bind(newConfig: SportPlayerConfig?) {
        release()
        config = newConfig
        bitrateHistory.clear()
        userPaused = false
        isMuted = true
        isPlaying = false
        if (newConfig == null) return
        player = SportLivePlayer(context).apply {
            setListener(listener)
            bindTextureView(texture)
            setConfig(newConfig)
            setMute(isMuted)
        }
    }

    fun play(fromUser: Boolean = false) {
        val p = player ?: return
        if (fromUser) userPaused = false
        p.setMute(isMuted)
        p.play()
        isPlaying = true
    }

    fun playIfAllowed() {
        if (!userPaused) play()
    }

    fun pause(fromUser: Boolean = false) {
        if (fromUser) userPaused = true
        player?.pause()
        isPlaying = false
    }

    fun setMuted(mute: Boolean) {
        isMuted = mute
        player?.setMute(mute)
    }

    fun setSrEnabled(enable: Boolean) = player?.setSrEnabled(enable)

    fun setSharpenEnabled(enable: Boolean) = player?.setSharpenEnabled(enable)

    fun release() {
        player?.destroy()
        player = null
        config = null
        isPlaying = false
        isMuted = true
        userPaused = false
    }

    companion object {
        private const val BITRATE_CAPACITY = 60
    }
}
