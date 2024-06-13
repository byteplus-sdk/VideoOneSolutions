// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoGestureLayer extends GestureLayer {

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = super.createView(parent);
        if (view != null) {
            view.setEnabled(PlayScene.isFullScreenMode(playScene()));
        }
        return view;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        super.onVideoViewPlaySceneChanged(fromScene, toScene);
        View view = getView();
        if (view != null) {
            view.setEnabled(PlayScene.isFullScreenMode(toScene));
        }

        if (PlayScene.isFullScreenMode(toScene)) {
            showController();
        }
    }
}
