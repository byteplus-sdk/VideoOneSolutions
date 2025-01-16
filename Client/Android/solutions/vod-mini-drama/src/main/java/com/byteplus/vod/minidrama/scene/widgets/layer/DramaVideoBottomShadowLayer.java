// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.utils.ViewUtils;

public class DramaVideoBottomShadowLayer extends BaseLayer {

    @Nullable
    @Override
    public String tag() {
        return "ShortVideoBottomShadowLayer";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = new View(parent.getContext());
        view.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (int) ViewUtils.dp2px(280), Gravity.BOTTOM));
        view.setBackground(ContextCompat.getDrawable(parent.getContext(), R.drawable.vevod_short_video_bottom_shadow));
        return view;
    }

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        super.onBindVideoView(videoView);
        show();
    }
}
