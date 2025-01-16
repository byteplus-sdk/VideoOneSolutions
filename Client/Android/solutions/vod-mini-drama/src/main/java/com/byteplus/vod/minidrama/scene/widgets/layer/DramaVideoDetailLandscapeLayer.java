// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TimeProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.VolumeBrightnessIconLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;

public class DramaVideoDetailLandscapeLayer extends DramaVideoLayer {

    private boolean mIsLockedIntercepted = false;

    private final Dispatcher.EventListener mEventListener = this::onPlaybackEvent;

    public DramaVideoDetailLandscapeLayer() {
        super(Type.DETAIL_LANDSCAPE);
    }

    @CallSuper
    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mEventListener);
    }

    @CallSuper
    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mEventListener);
    }

    protected void onPlaybackEvent(Event event) {
        if (event.code() == PlayerEvent.Action.PREPARE && mIsLockedIntercepted) {
            dismissLayers(true);
            mIsLockedIntercepted = false;
        }

    }

    @Override
    public void onVideoViewStartPlaybackIntercepted(VideoView videoView, String reason) {
        super.onVideoViewStartPlaybackIntercepted(videoView, reason);
        if (INTERCEPT_START_PLAYBACK_REASON_LOCKED.equals(reason)) {
            mIsLockedIntercepted = true;
            AnimateLayer timeProgressLayer = findLayer(TimeProgressBarLayer.class);
            if (timeProgressLayer != null) {
                timeProgressLayer.animateShow(false);
            }
            AnimateLayer playPauseLayer = findLayer(PlayPauseLayer.class);
            if (playPauseLayer != null) {
                playPauseLayer.animateShow(false);
            }
            AnimateLayer titleBarLayer = findLayer(TitleBarLayer.class);
            if (titleBarLayer != null) {
                titleBarLayer.animateShow(false);
            }
            AnimateLayer volumeBrightnessIconLayer = findLayer(VolumeBrightnessIconLayer.class);
            if (volumeBrightnessIconLayer != null) {
                volumeBrightnessIconLayer.animateShow(false);
            }
            dismissLayers(false);
        }
    }

    private void dismissLayers(boolean dismiss) {
        VideoLayerHost layerHost = layerHost();
        if (layerHost == null) {
            return;
        }
        for (int i = 0; i < layerHost.layerSize(); i++) {
            VideoLayer layer = layerHost.findLayer(i);
            if (layer instanceof DialogLayer) {
                ((DialogLayer) layer).setDismissOtherLayers(dismiss);
            }
        }
    }
}
