// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.List;


public class GestureLayer extends PlaybackEventLayer {

    boolean isActive(int scene) {
        return scene == PlayScene.SCENE_DETAIL || PlayScene.isFullScreenMode(scene);
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

        final Player player = player();
        boolean autoDismiss = player == null || !player.isPaused();

        List<? extends VideoLayer> layers = host.findLayersByTag(GestureControllable.class);
        final boolean active = isActive(playScene());
        for (VideoLayer layer : layers) {
            if (layer instanceof GestureCheckActive && !active) {
                continue;
            }

            if (layer instanceof AnimateLayer animateLayer) {
                animateLayer.animateShow(autoDismiss);
            } else {
                layer.show();
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
        List<? extends VideoLayer> layers = host.findLayersByTag(GestureControllable.class);
        for (VideoLayer layer : layers) {
            if (layer instanceof GestureCheckActive &&!isActive(playScene())) {
                continue;
            }
            if (layer instanceof AnimateLayer animateLayer) {
                animateLayer.animateDismiss(force);
            } else {
                layer.dismiss();
            }
        }
    }

    public boolean isControllerShowing() {
        final VideoLayerHost host = layerHost();
        if (host == null) return false;
        final TimeProgressBarLayer layer = host.findLayer(TimeProgressBarLayer.class);
        return layer != null && layer.isShowing();
    }
}
