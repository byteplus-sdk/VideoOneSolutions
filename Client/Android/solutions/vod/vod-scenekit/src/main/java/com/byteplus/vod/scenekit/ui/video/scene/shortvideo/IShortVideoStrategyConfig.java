// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

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
