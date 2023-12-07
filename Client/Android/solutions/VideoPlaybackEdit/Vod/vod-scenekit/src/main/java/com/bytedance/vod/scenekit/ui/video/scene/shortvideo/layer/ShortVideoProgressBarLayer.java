// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.vod.scenekit.ui.video.layer.SimpleProgressBarLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoProgressBarLayer extends SimpleProgressBarLayer {

    public ShortVideoProgressBarLayer() {
        super(false);
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = super.createView(parent);
        mSeekBar.setTextVisibility(false);
        mSeekBar.enableHideThumb();
        return view;
    }

    @Override
    public void show() {
        if (playScene() == PlayScene.SCENE_FULLSCREEN) {
            return;
        }
        // PM: Only show progress bar when duration > 1 Min
        final Player player = player();
        if (player != null && player.getDuration() > 60 * 1000) {
            super.show();
        }
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        super.onVideoViewPlaySceneChanged(fromScene, toScene);
        if (fromScene == PlayScene.SCENE_FULLSCREEN && toScene != PlayScene.SCENE_FULLSCREEN) {
            // exit full screen
            show();
        } else if (fromScene != PlayScene.SCENE_FULLSCREEN && toScene == PlayScene.SCENE_FULLSCREEN) {
            // enter full screen
            dismiss();
        }
    }
}
