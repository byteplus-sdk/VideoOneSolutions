package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.bytedance.vod.scenekit.ui.video.layer.TitleBarLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoFullScreenTitleBarLayer extends TitleBarLayer {
    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (toScene == PlayScene.SCENE_FULLSCREEN) {
            show();
        } else {
            super.onVideoViewPlaySceneChanged(fromScene, toScene);
        }
    }
}
