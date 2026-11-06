// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.byteplus.minidrama.databinding.VevodMiniDramaCoverVideoLayerBinding;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;


public class DramaVideoCoverLayer extends CoverLayer {
    @Override
    public String tag() {
        return "drama_video_cover";
    }

    private VevodMiniDramaCoverVideoLayerBinding binding;

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        binding = VevodMiniDramaCoverVideoLayerBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return binding.getRoot();
    }

    @Override
    protected ImageView getImageView() {
        return binding.displayCover;
    }

    // 预渲染实例由页面移交给 PlaybackController；封面沿用 CoverLayer 的真实首帧事件。
    // 不再从 SDK 的全局预渲染池取实例，也不因只拿到宽高就提前隐藏封面。

    public void updateDisplayAnchor(int width, int height) {
        ConstraintLayout.LayoutParams params = (ConstraintLayout.LayoutParams) binding.displayCover.getLayoutParams();
        params.dimensionRatio = width + ":" + height;
        DramaVideoLayerRecommend layer = findLayer(DramaVideoLayerRecommend.class);
        if (layer != null) {
            layer.updateDisplayAnchor(width, height);
        }
    }

    public void updateDisplayFullScreen() {
        ConstraintLayout.LayoutParams params = (ConstraintLayout.LayoutParams) binding.displayCover.getLayoutParams();
        params.dimensionRatio = null;
        DramaVideoLayerRecommend layer = findLayer(DramaVideoLayerRecommend.class);
        if (layer != null) {
            layer.updateDisplayFullScreen();
        }
    }
}
