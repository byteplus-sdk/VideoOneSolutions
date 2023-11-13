// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.vod.scenekit.ui.video.layer.SimpleProgressBarLayer;

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
        // PM: Only show progress bar when duration > 1 Min
        final Player player = player();
        if (player != null && player.getDuration() > 60 * 1000) {
            super.show();
        }
    }
}
