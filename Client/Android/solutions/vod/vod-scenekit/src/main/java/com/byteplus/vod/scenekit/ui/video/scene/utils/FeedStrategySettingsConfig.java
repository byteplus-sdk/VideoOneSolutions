package com.byteplus.vod.scenekit.ui.video.scene.utils;

import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.IFeedVideoStrategyConfig;

public class FeedStrategySettingsConfig implements IFeedVideoStrategyConfig {
    @Override
    public boolean miniPlayerEnabled() {
        return true;
    }
}
