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
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.utils.ProgressRecorder;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniDramaVideoStrategy;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;


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

    @Override
    protected void handleEvent(int code, @Nullable Object obj) {
        super.handleEvent(code, obj);
        if (code == Layers.Event.VIEW_PAGER_ON_PAGE_PEEK_START.ordinal()) {
            startPreRenderCover("ViewPager#onPagePeekStart");
        }
    }

    public void startPreRenderCover(String reason) {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        if (videoView.getSurface() == null || !videoView.getSurface().isValid()) return;

        if (player() != null) {
            return;
        }

        final boolean rendered = MiniDramaVideoStrategy.renderFrame(videoView);
        if (rendered) {
            L.d(this, "startPreRenderCover", reason, videoView, videoView.getSurface(), "preRender success");
            if (!isPreRenderWithStartTime() && videoView.getDisplayViewType() == DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW) {
                dismiss();
            }
        } else {
            L.d(this, "startPreRenderCover", reason, videoView, videoView.getSurface(), "preRender failed");
        }
    }

    private boolean isPreRenderWithStartTime() {
        MediaSource mediaSource = dataSource();
        if (mediaSource == null) return false;
        return ProgressRecorder.getProgress(mediaSource.getSyncProgressId()) > 0;
    }

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
