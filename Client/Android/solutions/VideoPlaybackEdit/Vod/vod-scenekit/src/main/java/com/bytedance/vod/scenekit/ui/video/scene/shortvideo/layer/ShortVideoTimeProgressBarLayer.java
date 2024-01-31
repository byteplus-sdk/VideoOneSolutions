package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.bytedance.vod.scenekit.ui.video.layer.TimeProgressBarLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

/**
 * Only show when full screen mode
 */
public class ShortVideoTimeProgressBarLayer extends TimeProgressBarLayer {
    @Override
    protected boolean checkShow() {
        return PlayScene.isFullScreenMode(playScene());
    }
}
