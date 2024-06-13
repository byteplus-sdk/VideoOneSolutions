// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class PlayPauseLayer extends AnimateLayer {
    private ImageView mPreviousIv;
    private ImageView mPlayIv;
    private ImageView mNextIv;

    @Override
    public String tag() {
        return "play_pause";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        final View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_play_pause_layer, parent, false);
        mPreviousIv = view.findViewById(R.id.previous);
        mPlayIv = view.findViewById(R.id.play);
        mNextIv = view.findViewById(R.id.next);
        mPlayIv.setOnClickListener(v -> togglePlayPause());
        return view;
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
        show();
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
        show();
    }

    @Override
    protected boolean preventAnimateDismiss() {
        final Player player = player();
        return player != null && player.isPaused();
    }

    @Override
    public void animateShow(boolean autoDismiss) {
        PlayCompleteLayer layer = findLayer(PlayCompleteLayer.class);
        if (layer != null && layer.isShowing()) {
            // Exclusive with PlayCompleteLayer
            return;
        }

        super.animateShow(autoDismiss);
    }

    protected void togglePlayPause() {
        final Player player = player();
        if (player != null) {
            if (player.isPlaying()) {
                player.pause();
            } else if (player.isPaused() || player.isCompleted()) {
                player.start();
            } else {
                L.e(PlayPauseLayer.this, "wrong state", player.dump());
            }
        } else {
            startPlayback();
        }
    }

    protected void setPlayPause(boolean isPlay) {
        final ImageView playButton = mPlayIv;
        if (playButton == null) return;

        playButton.setSelected(isPlay);
    }

    protected void syncState() {
        final PlaybackController controller = controller();
        if (controller != null) {
            final Player player = controller.player();
            if (player != null) {
                setPlayPause(player.isPlaying());
            } else {
                setPlayPause(false);
            }
        } else {
            setPlayPause(false);
        }
    }

    private void syncTheme() {
        final ImageView playButton = mPlayIv;
        if (playButton == null) return;
        VideoView videoView = videoView();
        if (videoView == null) return;
        int size;
        if (PlayScene.isFullScreenMode(playScene())) {
            playButton.setImageDrawable(ResourcesCompat.getDrawable(playButton.getResources(),
                    R.drawable.vevod_play_pause_layer_fullscreen_ic_selector, null));
            size = (int) UIUtils.dip2Px(context(), 48);
        } else {
            playButton.setImageDrawable(ResourcesCompat.getDrawable(playButton.getResources(),
                    R.drawable.vevod_play_pause_layer_halfscreen_ic_selector, null));
            size = (int) UIUtils.dip2Px(context(), 40);
        }
        playButton.getLayoutParams().width = size;
        playButton.getLayoutParams().height = size;
        playButton.requestLayout();
        if (mPreviousIv.getVisibility() == View.VISIBLE) {
            mPreviousIv.getLayoutParams().width = size;
            mPreviousIv.getLayoutParams().height = size;
            mPreviousIv.requestLayout();
        }
        if (mNextIv.getVisibility() == View.VISIBLE) {
            mNextIv.getLayoutParams().width = size;
            mNextIv.getLayoutParams().height = size;
            mNextIv.requestLayout();
        }
    }

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK: {
                if (player() == null) {
                    dismiss();
                }
                break;
            }
            case PlayerEvent.State.STARTED:
            case PlayerEvent.State.PAUSED: {
                syncState();
                break;
            }
            case PlayerEvent.State.COMPLETED: {
                syncState();
                dismiss();
                break;
            }
            case PlayerEvent.State.STOPPED:
            case PlayerEvent.State.RELEASED: {
                show();
                break;
            }
            case PlayerEvent.State.ERROR:
            case PlayerEvent.Info.BUFFERING_END:
            case PlayerEvent.Info.BUFFERING_START: {
                dismiss();
                break;
            }
        }
    };

    @Override
    public void show() {
        if (!checkShow()) {
            return;
        }
        super.show();
        syncState();
        syncTheme();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (checkShow()) {
            syncState();
            syncTheme();
        } else {
            dismiss();
        }
    }

    public void showPreviousBtn(boolean show) {
        mPreviousIv.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public void showNextBtn(boolean show) {
        mNextIv.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public void setPreviousBtnOnClickListener(View.OnClickListener listener) {
        mPreviousIv.setOnClickListener(listener);
    }

    public void setNextBtnOnClickListener(View.OnClickListener listener) {
        mNextIv.setOnClickListener(listener);
    }

    protected boolean checkShow() {
        return true;
    }
}
