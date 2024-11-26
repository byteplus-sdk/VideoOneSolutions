// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;

import com.byteplus.playerkit.player.Player;
import com.byteplus.vod.scenekit.ui.video.layer.SimpleProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.OnApplyInsetsListener;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoProgressBarLayer extends SimpleProgressBarLayer implements OnApplyInsetsListener {

    public ShortVideoProgressBarLayer() {
        super(false);
    }

    @NonNull
    private Insets insets = Insets.NONE;

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = super.createView(parent);
        mSeekBar.setTextVisibility(false);
        mSeekBar.enableHideThumb();
        applySeekBarLayoutParams();
        return view;
    }

    @Override
    public void show() {
        if (PlayScene.isFullScreenMode(playScene())) {
            return;
        }
        // PM: Only show progress bar when duration > 1 Min
        final Player player = player();
        if (player != null && player.getDuration() > 60 * 1000) {
            super.show();
        }
    }

    @Override
    public void onApplyInsets(@NonNull Insets insets) {
        this.insets = insets;
        applySeekBarLayoutParams();
    }

    private void applySeekBarLayoutParams() {
        if (mSeekBar == null) {
            return;
        }
        ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) mSeekBar.getLayoutParams();
        params.bottomMargin = insets.bottom;

        mSeekBar.setLayoutParams(params);
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        super.onVideoViewPlaySceneChanged(fromScene, toScene);
        if (PlayScene.isFullScreenMode(fromScene) && !PlayScene.isFullScreenMode(toScene)) {
            // exit full screen
            show();
        } else if (!PlayScene.isFullScreenMode(fromScene) && PlayScene.isFullScreenMode(toScene)) {
            // enter full screen
            dismiss();
        }
    }
}
