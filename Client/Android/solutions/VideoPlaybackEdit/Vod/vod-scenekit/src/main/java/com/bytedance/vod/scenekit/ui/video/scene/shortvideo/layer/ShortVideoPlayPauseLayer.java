package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import com.bytedance.vod.scenekit.ui.video.layer.PlayPauseLayer;

public class ShortVideoPlayPauseLayer extends PlayPauseLayer {
    @Override
    protected boolean checkShow() {
        return isFullScreenMode(playScene());
    }
}
