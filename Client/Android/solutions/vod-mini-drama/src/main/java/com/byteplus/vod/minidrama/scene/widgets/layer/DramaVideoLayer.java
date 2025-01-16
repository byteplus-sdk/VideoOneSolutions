// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.event.EpisodePlayLockedEvent;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;

public class DramaVideoLayer extends AnimateLayer {
    public static final String INTERCEPT_START_PLAYBACK_REASON_LOCKED = "locked";
    public static final String INTERCEPT_START_PLAYBACK_REASON_EMPTY = "empty";

    public static DramaVideoLayer create(Type type) {
        return switch (type) {
            case DETAIL -> new DramaVideoLayerDetail();
            case RECOMMEND -> new DramaVideoLayerRecommend();
            case DETAIL_LANDSCAPE -> new DramaVideoDetailLandscapeLayer();
        };
    }

    protected final Type mType;

    public enum Type {
        DETAIL,
        DETAIL_LANDSCAPE,
        RECOMMEND
    }

    protected DramaVideoLayer(Type type) {
        this.mType = type;
    }

    @Override
    public void onVideoViewBindDataSource(MediaSource dataSource) {
        super.onVideoViewBindDataSource(dataSource);
        updateUI();
    }


    @Override
    public void onVideoViewStartPlaybackIntercepted(VideoView videoView, String reason) {
        if (INTERCEPT_START_PLAYBACK_REASON_LOCKED.equals(reason)) {
            VideoItem videoItem = VideoViewExtras.getVideoItem(videoView);
            MiniEventBus.post(new EpisodePlayLockedEvent(videoItem));
        }
    }

    @Nullable
    @Override
    public String tag() {
        return "drama_video";
    }

    private final VideoView.VideoViewPlaybackActionInterceptor interceptor = new VideoView.VideoViewPlaybackActionInterceptor() {
        @Override
        public String onVideoViewInterceptStartPlayback(VideoView videoView) {
            VideoItem videoItem = VideoItem.get(dataSource());
            if (videoItem == null) {
                return null;
            }

            DramaFeed feed = DramaFeed.of(videoItem);
            if (feed.isLocked()) {
                // intercept
                L.d(this, "onVideoViewInterceptStartPlayback", "Episode video [" + VideoItem.dump(videoItem) + "] is locked.");
                return INTERCEPT_START_PLAYBACK_REASON_LOCKED;
            }
            if (videoItem.getSourceType() == VideoItem.SOURCE_TYPE_EMPTY) {
                // intercept
                L.d(this, "onVideoViewInterceptStartPlayback", "Episode video [" + VideoItem.dump(videoItem) + "] is empty.");
                return INTERCEPT_START_PLAYBACK_REASON_EMPTY;
            }
            return null;
        }
    };

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        super.onBindVideoView(videoView);
        show();
        videoView.addPlaybackInterceptor(1, interceptor);
    }

    @Override
    protected void onUnBindVideoView(@NonNull VideoView videoView) {
        super.onUnBindVideoView(videoView);
        videoView.removePlaybackInterceptor(1, interceptor);
    }

    @Override
    public void show() {
        super.show();
        updateUI();
    }

    protected void updateUI() {

    }

    public void onDoubleTap() {

    }
}
