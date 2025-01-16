// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewholder;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoBottomShadowLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoCoverLayer;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayerConfigLayer;
import com.byteplus.vod.scenekit.ui.video.layer.SimpleProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.List;

public class DramaVideoItemViewHolder extends VideoViewHolder {
    public final FrameLayout videoViewContainer;
    public final VideoView videoView;
    public VideoItem videoItem;

    public DramaVideoItemViewHolder(@NonNull View itemView) {
        super(itemView);
        this.videoViewContainer = (FrameLayout) itemView;
        this.videoViewContainer.setLayoutParams(new RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.MATCH_PARENT));
        this.videoView = createVideoView(videoViewContainer);
    }

    @Override
    public VideoView videoView() {
        return videoView;
    }

    @Override
    public void bind(List<ViewItem> items, int position) {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        final ViewItem item = items.get(position);
        this.videoItem = (VideoItem) item;
        MediaSource mediaSource = videoView.getDataSource();
        if (mediaSource == null) {
            mediaSource = VideoItem.toMediaSource(videoItem);
            videoView.bindDataSource(mediaSource);
        } else {
            if (!TextUtils.equals(videoItem.getVid(), mediaSource.getMediaId())) {
                videoView.stopPlayback();
                mediaSource = VideoItem.toMediaSource(videoItem);
                videoView.bindDataSource(mediaSource);
            } else {
                // vid is same
                if (videoView.player() == null) {
                    mediaSource = VideoItem.toMediaSource(videoItem);
                    videoView.bindDataSource(mediaSource);
                } else {
                    // do nothing
                }
            }
        }
    }

    @Override
    public ViewItem getBindingItem() {
        return videoItem;
    }

    @NonNull
    private static VideoView createVideoView(@NonNull FrameLayout parent) {
        VideoView videoView = new VideoView(parent.getContext());
        VideoLayerHost layerHost = new VideoLayerHost(parent.getContext());
        layerHost.addLayer(new PlayerConfigLayer());
        layerHost.addLayer(new DramaVideoCoverLayer());
        layerHost.addLayer(new DramaVideoBottomShadowLayer());
        layerHost.addLayer(new LoadingLayer());
        layerHost.addLayer(new PauseLayer());
        layerHost.addLayer(new SimpleProgressBarLayer(false));
        layerHost.addLayer(new PlayErrorLayer());
        if (VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)) {
            layerHost.addLayer(new LogLayer());
        }
        layerHost.attachToVideoView(videoView);
        videoView.setBackgroundColor(parent.getResources().getColor(android.R.color.black));
        //videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT); // fit mode
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL); // immersive mode
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        videoView.setPlayScene(PlayScene.SCENE_SHORT);
        new PlaybackController().bind(videoView);
        parent.addView(videoView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        return videoView;
    }
}