// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.DoubleTapHeartHelper;
import com.byteplus.vod.scenekit.utils.GestureHelper;

import java.lang.ref.WeakReference;

public class DramaGestureLayer extends BaseLayer {

    public interface DramaGestureContract {

        default boolean isSpeedIndicatorShowing() {
            return false;
        }

        default void showSpeedIndicator(boolean show) {
        }
    }

    private final WeakReference<DramaGestureContract> mContractRef;

    public DramaGestureLayer(DramaGestureContract contract) {
        this.mContractRef = new WeakReference<>(contract);
    }

    @Nullable
    @Override
    public String tag() {
        return "drama_gesture";
    }

    private ViewGroup parent;

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        this.parent = parent;
        View view = new View(parent.getContext());
        view.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        Gesture gesture = new Gesture(parent.getContext(), this);
        view.setOnTouchListener(gesture::onTouchEvent);
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
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onBindLayerHost(layerHost);
        show();
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
            if (event.code() == PlaybackEvent.Action.STOP_PLAYBACK
                    || event.code() == PlaybackEvent.Action.START_PLAYBACK) {
                dismissSpeed();
            }
        }
    };

    private static class Gesture extends GestureHelper {
        private WeakReference<DramaGestureLayer> mLayerRef;

        public Gesture(Context context, DramaGestureLayer layer) {
            super(context);
            this.mLayerRef = new WeakReference<>(layer);
        }

        private boolean check() {
            DramaGestureLayer gestureLayer = mLayerRef.get();
            if (gestureLayer == null) return false;

            View view = gestureLayer.getView();
            if (view == null) return false;

            Player player = gestureLayer.player();
            return player != null && player.isInPlaybackState();
        }

        @Override
        public boolean onDown(MotionEvent e) {
            return check();
        }

        @Override
        public void onLongPress(MotionEvent e) {
            final DramaGestureLayer layer = mLayerRef.get();
            if (layer == null) return;

            layer.onLongPress();
        }

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {

            final DramaGestureLayer layer = mLayerRef.get();
            if (layer == null) return super.onSingleTapConfirmed(e);
            return layer.onSingleTapConfirmed();
        }

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            final DramaGestureLayer layer = mLayerRef.get();
            if (layer == null) return super.onDoubleTap(e);
            return layer.onDoubleTapConfirmed((int) e.getX(), (int) e.getY());
        }

        @Override
        public boolean onUp(MotionEvent e) {
            final DramaGestureLayer layer = mLayerRef.get();
            if (layer == null) return false;

            return layer.onUp(e);
        }

        @Override
        public boolean onCancel(MotionEvent e) {
            final DramaGestureLayer layer = mLayerRef.get();
            if (layer == null) return false;
            return layer.onCancel(e);
        }
    }

    private boolean onCancel(MotionEvent e) {
        L.d(this, "onCancel");
        dismissSpeed();
        return false;
    }

    private boolean onUp(MotionEvent e) {
        L.d(this, "onUp");
        dismissSpeed();
        return false;
    }

    private boolean onSingleTapConfirmed() {
        final VideoView videoView = videoView();
        if (videoView == null) return false;

        L.d(this, "onSingleTapConfirmed");

        videoView.performClick();

        return true;
    }

    private boolean onDoubleTapConfirmed(int x, int y) {
        DramaVideoLayer layer = findLayer(DramaVideoLayer.class);
        if (layer != null) {
            layer.onDoubleTap();
            if(parent != null) {
                DoubleTapHeartHelper.show(parent, x, y);
            }
        }
        return false;
    }

    private void onLongPress() {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        L.d(this, "onLongPress");

        videoView.performLongClick();

        showSpeed();
    }

    private void showSpeed() {
        final DramaGestureContract contract = mContractRef == null ? null : mContractRef.get();
        if (contract == null || contract.isSpeedIndicatorShowing()) return;

        L.d(this, "showSpeed");

        final Player player = player();
        if (player == null || !player.isPlaying()) return;

        player.setSpeed(2.0f);
        contract.showSpeedIndicator(true);

        VideoLayerHost host = layerHost();
        if (host != null) {
            DramaVideoLayer layer = host.findLayer(DramaVideoLayer.class);
            if (layer != null && layer.isShowing()) {
                layer.dismiss();
            }
        }
    }

    private void dismissSpeed() {
        final DramaGestureContract contract = mContractRef == null ? null : mContractRef.get();
        if (contract == null || !contract.isSpeedIndicatorShowing()) return;

        L.d(this, "dismissSpeed");

        final Player player = player();
        if (player == null) return;
        player.setSpeed(1f);

        contract.showSpeedIndicator(false);
        VideoLayerHost host = layerHost();
        if (host != null) {
            DramaVideoLayer layer = host.findLayer(DramaVideoLayer.class);
            if (layer != null && !layer.isShowing()) {
                layer.animateShow(false);
            }
        }
    }
}
