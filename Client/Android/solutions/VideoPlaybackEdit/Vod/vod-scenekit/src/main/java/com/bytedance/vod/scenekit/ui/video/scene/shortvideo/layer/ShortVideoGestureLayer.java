package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoGestureLayer extends GestureLayer {

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = super.createView(parent);
        if (view != null) {
            view.setEnabled(playScene() == PlayScene.SCENE_FULLSCREEN);
        }
        return view;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        super.onVideoViewPlaySceneChanged(fromScene, toScene);
        View view = getView();
        if (view != null) {
            view.setEnabled(toScene == PlayScene.SCENE_FULLSCREEN);
        }

        if (toScene == PlayScene.SCENE_FULLSCREEN) {
            showController();
        }
    }
}
