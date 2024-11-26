package com.byteplus.vodlive.utils

import com.byteplus.playerkit.player.source.MediaSource
import com.byteplus.playerkit.player.ve.SceneFeed
import com.byteplus.playerkit.player.ve.VEPlayerStatic

object StrategyManager {
    fun enable() {
        // Enable short video preload & pre-render strategy
        VEPlayerStatic.setSceneStrategyEnabled(SceneFeed.SCENE_SHORT_VIDEO, true)
    }

    /**
     * Set preload sources
     */
    fun setMediaSources(sources: List<MediaSource>) = VEPlayerStatic.setMediaSources(sources)

    /**
     * Append preload sources
     */
    fun appendMediaSources(sources: List<MediaSource>) = VEPlayerStatic.addMediaSources(sources)

    fun startPreload() {
        // Not support dynamic control yet
    }

    fun stopPreload() {
        // Not support dynamic control yet
    }
}