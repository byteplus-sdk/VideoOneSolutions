// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.utils.L;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;


public class GestureLayer extends PlaybackEventLayer {

    boolean isActive(int scene) {
        return scene == PlayScene.SCENE_DETAIL || isFullScreenMode(scene);
    }

    @Override
    public String tag() {
        return "gesture";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        final View view = new View(parent.getContext());
        final GestureLayerHelper gesture = new GestureLayerHelper(parent.getContext(), this);
        view.setOnTouchListener(gesture::onTouchEvent);
        view.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        return view;
    }

    @Override
    public void requestDismiss(@NonNull String reason) {
        // super.requestDismiss(reason);
    }

    @Override
    public void requestHide(@NonNull String reason) {
        // super.requestHide(reason);
    }

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        super.onBindVideoView(videoView);
        show();
    }

    @Override
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onBindLayerHost(layerHost);
        show();
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        if (event.code() == PlayerEvent.State.STARTED) {
            dismissController();
        }
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return;

        if (!isActive(toScene)) {
            VolumeBrightnessIconLayer volumeBrightnessIconLayer =
                    layerHost.findLayer(VolumeBrightnessIconLayer.class);
            LockLayer lockLayer = layerHost.findLayer(LockLayer.class);
            if (volumeBrightnessIconLayer != null) {
                volumeBrightnessIconLayer.dismiss();
            }
            if (lockLayer != null) {
                lockLayer.dismiss();
            }
        }

        if (isControllerShowing()) {
            showController();
        }
    }

    @Override
    protected void onLayerHostLockStateChanged(boolean locked) {
        if (locked) {
            dismissController();
        } else {
            showController();
        }
    }

    public void toggleControllerVisibility() {
        if (isControllerShowing()) {
            dismissController(true);
        } else {
            showController();
        }
    }

    public void showController() {
        VideoLayerHost host = layerHost();
        if (host == null) return;

        L.d(this, "showController");

        // TODO opt layer dismiss logic
        final Player player = player();
        boolean autoDismiss = player == null || !player.isPaused();

        AnimateLayer timeProgressLayer = host.findLayer(TimeProgressBarLayer.class);
        AnimateLayer playPauseLayer = host.findLayer(PlayPauseLayer.class);
        AnimateLayer titleBarLayer = host.findLayer(TitleBarLayer.class);
        AnimateLayer volumeBrightnessIconLayer = host.findLayer(VolumeBrightnessIconLayer.class);

        AnimateLayer lockLayer = host.findLayer(LockLayer.class);

        if (timeProgressLayer != null) {
            timeProgressLayer.animateShow(autoDismiss);
        }
        if (playPauseLayer != null) {
            playPauseLayer.animateShow(autoDismiss);
        }
        if (titleBarLayer != null) {
            titleBarLayer.animateShow(autoDismiss);
        }
        if (isActive(playScene())) {
            if (volumeBrightnessIconLayer != null) {
                volumeBrightnessIconLayer.animateShow(autoDismiss);
            }
            if (lockLayer != null) {
                lockLayer.animateShow(autoDismiss);
            }
        }
    }

    public void dismissController() {
        dismissController(false);
    }

    public void dismissController(boolean force) {
        final VideoLayerHost host = layerHost();
        if (host == null) return;

        L.d(this, "dismissController");
        AnimateLayer timeProgressLayer = host.findLayer(TimeProgressBarLayer.class);
        AnimateLayer playPauseLayer = host.findLayer(PlayPauseLayer.class);
        AnimateLayer titleBarLayer = host.findLayer(TitleBarLayer.class);
        AnimateLayer volumeBrightnessIconLayer = host.findLayer(VolumeBrightnessIconLayer.class);

        AnimateLayer lockLayer = host.findLayer(LockLayer.class);

        if (timeProgressLayer != null) {
            timeProgressLayer.animateDismiss(force);
        }
        if (playPauseLayer != null) {
            playPauseLayer.animateDismiss(force);
        }
        if (titleBarLayer != null) {
            titleBarLayer.animateDismiss(force);
        }
        if (volumeBrightnessIconLayer != null) {
            volumeBrightnessIconLayer.animateDismiss(force);
        }
        if (lockLayer != null) {
            lockLayer.animateDismiss(force);
        }
    }

    public boolean isControllerShowing() {
        final VideoLayerHost host = layerHost();
        if (host == null) return false;
        final TimeProgressBarLayer layer = host.findLayer(TimeProgressBarLayer.class);
        return layer != null && layer.isShowing();
    }
}
