// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.utils

import com.byteplus.playerkit.player.source.MediaSource
import com.byteplus.playerkit.player.volcengine.VolcEngineStrategy
import com.byteplus.playerkit.player.volcengine.VolcScene


object StrategyManager {
    fun enable() {
        // Enable short video preload & pre-render strategy
        VolcEngineStrategy.setEnabled(
            VolcScene.SCENE_SHORT_VIDEO, true)
    }

    /**
     * Set preload sources
     */
    fun setMediaSources(sources: List<MediaSource>) = VolcEngineStrategy.setMediaSources(sources)

    /**
     * Append preload sources
     */
    fun appendMediaSources(sources: List<MediaSource>) = VolcEngineStrategy.addMediaSources(sources)

    fun startPreload() {
        // Not support dynamic control yet
    }

    fun stopPreload() {
        // Not support dynamic control yet
    }
}