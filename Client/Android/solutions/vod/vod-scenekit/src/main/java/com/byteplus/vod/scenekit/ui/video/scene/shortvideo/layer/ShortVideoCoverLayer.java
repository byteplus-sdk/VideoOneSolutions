// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.view.Surface;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.config.IImageCoverConfig;
import com.byteplus.vod.scenekit.ui.config.IPreRenderConfig;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.ShortVideoStrategy;

public class ShortVideoCoverLayer extends CoverLayer {

    @Override
    public String tag() {
        return "short_video_cover";
    }

    @Override
    public void onVideoViewBindDataSource(MediaSource dataSource) {
    }

    @Override
    public void onSurfaceAvailable(Surface surface, int width, int height) {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        if (player() != null) {
            return;
        }

        IPreRenderConfig config = getConfig();
        boolean enableStrategy = config != null && config.enableStrategy();
        final boolean rendered = enableStrategy && ShortVideoStrategy.renderFrame(videoView);
        if (rendered) {
            L.d(this, "onSurfaceAvailable", videoView, surface, "preRender success");
            dismiss();
        } else {
            L.d(this, "onSurfaceAvailable", videoView, surface, "preRender failed");
            show();
        }
    }

    @Override
    protected void load() {
        IImageCoverConfig config = getConfig();
        if (config != null && config.enableCover()) {
            super.load();
        }
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlayerEvent.Info.VIDEO_RENDERING_START: {
                    dismiss();
                    break;
                }
            }
        }
    };
}
