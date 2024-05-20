// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.settingskit.Option;

public class FullScreenTipsLayer extends AnimateLayer {
    @Nullable
    @Override
    public String tag() {
        return "full-screen-tips";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_full_screen_tips_layer, parent, false);
        view.setOnClickListener(v -> dismiss());
        return view;
    }

    @Override
    public void show() {
        if (!PlayScene.isFullScreenMode(playScene())) {
            return;
        }
        super.show();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (PlayScene.isFullScreenMode(toScene)) {
            Option option = VideoSettings.option(VideoSettings.COMMON_SHOW_FULL_SCREEN_TIPS);
            if (option.booleanValue()) {
                animateShow(true);
                option.saveUserValue(Boolean.FALSE);
            }
        } else {
            dismiss();
        }
    }

    @Override
    protected long animateDismissDelay() {
        return 3000;
    }
}
