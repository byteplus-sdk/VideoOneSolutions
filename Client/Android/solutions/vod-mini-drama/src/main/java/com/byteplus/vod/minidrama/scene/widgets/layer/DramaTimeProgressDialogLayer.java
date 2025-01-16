// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;
import com.byteplus.vod.scenekit.utils.TimeUtils;

public class DramaTimeProgressDialogLayer extends DialogLayer {
    private TextView mCurrentProgressView;
    private TextView mDurationView;

    private long mCurrentPosition;

    @Nullable
    @Override
    public String tag() {
        return "drama_time_progress_dialog";
    }


    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_mini_drama_video_time_progress_dialog, parent, false);
        mCurrentProgressView = view.findViewById(R.id.currentProgress);
        mDurationView = view.findViewById(R.id.duration);
        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                final VideoLayerHost layerHost = layerHost();
                if (layerHost == null) return;
                final DramaVideoLayer dramaVideoLayer = layerHost.findLayer(DramaVideoLayer.class);
                if (dramaVideoLayer != null) {
                    dramaVideoLayer.animateShow(false);
                }
                final PauseLayer pauseLayer = layerHost.findLayer(PauseLayer.class);
                if (pauseLayer != null) {
                    Player player = player();
                    if (player != null && player.isPaused()) {
                        pauseLayer.animateShow(false);
                    }
                }
            }
        });
        return view;
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.TIME_PROGRESS_DIALOG_LAYER_PRIORITY;
    }

    public void setCurrentPosition(long currentPosition, long duration) {
        mCurrentPosition = currentPosition;
        if (isShowing()) {
            mCurrentProgressView.setText(TimeUtils.time2String(currentPosition));
            mDurationView.setText(TimeUtils.time2String(duration));
        }
    }

    private void syncPosition() {
        Player player = player();
        if (player == null || !player.isInPlaybackState()) return;
        if (mCurrentPosition == 0) {
            mCurrentPosition = player.getCurrentPosition();
        }
        setCurrentPosition(mCurrentPosition, player.getDuration());
    }

    @Override
    public void show() {
        super.show();
        syncPosition();
    }

    public long getCurrentPosition() {
        return mCurrentPosition;
    }

    @Override
    public void animateDismiss() {
        super.animateDismiss();
    }
}
