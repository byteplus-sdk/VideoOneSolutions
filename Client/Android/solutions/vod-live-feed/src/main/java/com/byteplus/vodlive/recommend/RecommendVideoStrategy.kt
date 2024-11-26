package com.byteplus.vodlive.recommend

import com.byteplus.vod.scenekit.VideoSettings
import com.byteplus.vod.scenekit.ui.config.ICompleteAction
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.IShortVideoStrategyConfig

object RecommendVideoStrategy : IShortVideoStrategyConfig {
    override fun enableStrategy(): Boolean = true

    override fun enableCover(): Boolean = true

    override fun completeAction(): Int = ICompleteAction.LOOP

    override fun enableLogLayer(): Boolean {
        return VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)
    }
}