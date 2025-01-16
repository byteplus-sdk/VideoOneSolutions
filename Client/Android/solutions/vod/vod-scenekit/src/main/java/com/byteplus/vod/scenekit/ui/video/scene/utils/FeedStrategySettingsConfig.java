// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.utils;

import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.IFeedVideoStrategyConfig;

public class FeedStrategySettingsConfig implements IFeedVideoStrategyConfig {
    @Override
    public boolean miniPlayerEnabled() {
        return true;
    }
}
