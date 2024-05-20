// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.byteplus.vod.scenekit.ui.video.layer.TimeProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

/**
 * Only show when full screen mode
 */
public class ShortVideoTimeProgressBarLayer extends TimeProgressBarLayer {
    @Override
    protected boolean checkShow() {
        return PlayScene.isFullScreenMode(playScene());
    }
}
