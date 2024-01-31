package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;

public class ShortVideoGestureLayer extends GestureLayer {

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = super.createView(parent);
        if (view != null) {
            view.setEnabled(isFullScreenMode(playScene()));
        }
        return view;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        super.onVideoViewPlaySceneChanged(fromScene, toScene);
        View view = getView();
        if (view != null) {
            view.setEnabled(isFullScreenMode(toScene));
        }

        if (isFullScreenMode(toScene)) {
            showController();
        }
    }
}
