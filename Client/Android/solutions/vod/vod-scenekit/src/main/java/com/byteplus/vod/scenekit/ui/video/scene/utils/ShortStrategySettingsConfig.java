// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.utils;

import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.IShortVideoStrategyConfig;

public class ShortStrategySettingsConfig implements IShortVideoStrategyConfig {
    @Override
    public boolean enableStrategy() {
        return VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_STRATEGY);
    }

    @Override
    public boolean enableCover() {
        return VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_IMAGE_COVER);
    }

    @Override
    public int completeAction() {
        return VideoSettings.intValue(VideoSettings.SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION);
    }

    @Override
    public boolean enableLogLayer() {
        return VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER);
    }
}