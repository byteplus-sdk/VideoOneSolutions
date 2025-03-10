// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewholder;

import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.scene.widgets.MDMediaSeekBar;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaBottomProgressBarLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaGestureLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaTimeProgressDialogLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoBottomShadowLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoCoverLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoPlayerConfigLayer;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.ViewUtils;

import java.util.List;

public class DramaEpisodeVideoViewHolder extends VideoViewHolder {
    public final FrameLayout videoViewContainer;
    public final VideoView videoView;
    public VideoItem videoItem;

    public DramaEpisodeVideoViewHolder(@NonNull View itemView, DramaVideoLayer.Type type, DramaGestureLayer.DramaGestureContract gestureContract) {
        super(itemView);
        this.videoViewContainer = (FrameLayout) itemView;
        this.videoViewContainer.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        this.videoView = createVideoView(videoViewContainer, type, gestureContract);
    }

    @NonNull
    protected VideoView createVideoView(@NonNull FrameLayout parent, DramaVideoLayer.Type type, DramaGestureLayer.DramaGestureContract gestureContract) {
        VideoView videoView = new VideoView(parent.getContext());
        {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            params.bottomMargin = ViewUtils.dp2px(24);
            params.gravity = Gravity.CENTER_HORIZONTAL | Gravity.TOP;
            parent.addView(videoView, params);
        }

        MDMediaSeekBar seekBar = new MDMediaSeekBar(parent.getContext());
        {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(24));
            params.gravity = Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM;
            params.bottomMargin = ViewUtils.dp2px(1);
            parent.addView(seekBar, params);
        }

        VideoLayerHost layerHost = new VideoLayerHost(parent.getContext());
        layerHost.addLayer(new DramaGestureLayer(gestureContract));
        layerHost.addLayer(new DramaVideoCoverLayer());
        layerHost.addLayer(new DramaVideoBottomShadowLayer());
        layerHost.addLayer(DramaVideoLayer.create(type));
        layerHost.addLayer(DramaVideoPlayerConfigLayer.loop());
        layerHost.addLayer(new LoadingLayer());
        layerHost.addLayer(new PauseLayer());
        layerHost.addLayer(new DramaBottomProgressBarLayer(seekBar));
        layerHost.addLayer(new DramaTimeProgressDialogLayer());
        layerHost.addLayer(new PlayErrorLayer());
        if (VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)) {
            layerHost.addLayer(new LogLayer());
        }
        layerHost.attachToVideoView(videoView);
        //videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT); // fit mode
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL); // immersive mode
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        videoView.setPlayScene(PlayScene.SCENE_SHORT);
        new PlaybackController().bind(videoView);
        return videoView;
    }

    @Override
    public void bind(List<ViewItem> items, int position) {
        final ViewItem item = items.get(position);
        L.d(this, "bind", position, item);
        this.videoItem = (VideoItem) item;
        MediaSource mediaSource = videoView.getDataSource();
        VideoViewExtras.updateExtra(videoView, videoItem);
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
        VideoLayerHost layerHost = videoView.layerHost();
        DramaVideoCoverLayer videoCoverLayer;
        if (layerHost != null && (videoCoverLayer = layerHost.findLayer(DramaVideoCoverLayer.class)) != null) {
            if ((videoItem.getWidth() != 0 && videoItem.getHeight() != 0)
                    && videoItem.getWidth() > videoItem.getHeight()) {  // Support Landscape mode
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL_X);
                videoCoverLayer.updateDisplayAnchor(videoItem.getWidth(), videoItem.getHeight());
            } else { // Support Portrait mode
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL);
                videoCoverLayer.updateDisplayFullScreen();
            }
        }
    }

    public String getMediaId() {
        MediaSource mediaSource = videoView.getDataSource();
        return mediaSource == null ? null : mediaSource.getMediaId();
    }

    @Override
    public ViewItem getBindingItem() {
        return videoItem;
    }

    @Override
    public VideoView videoView() {
        return videoView;
    }
}
