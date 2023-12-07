package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.bytedance.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoPlayPauseLayer extends PlayPauseLayer {
    @Override
    protected boolean checkShow() {
        return playScene() == PlayScene.SCENE_FULLSCREEN;
    }
}
