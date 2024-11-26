package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;


import com.byteplus.vod.scenekit.ui.config.ICompleteAction;
import com.byteplus.vod.scenekit.ui.config.IDebugConfig;
import com.byteplus.vod.scenekit.ui.config.IImageCoverConfig;
import com.byteplus.vod.scenekit.ui.config.IPreRenderConfig;
import com.byteplus.vod.scenekit.ui.config.IPreloadConfig;

public interface IShortVideoStrategyConfig extends
        IPreRenderConfig,
        IPreloadConfig,
        IImageCoverConfig,
        ICompleteAction,
        IDebugConfig {
}
