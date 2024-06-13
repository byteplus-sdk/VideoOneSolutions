// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.byteplus.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoPlayPauseLayer extends PlayPauseLayer {
    @Override
    protected boolean checkShow() {
        return PlayScene.isFullScreenMode(playScene());
    }
}
