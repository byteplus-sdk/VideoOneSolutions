// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.utils.L;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.utils.UIUtils;

public class PlayPauseLayer extends AnimateLayer {

    @Override
    public String tag() {
        return "play_pause";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        final View ivPlayPause = (ImageView) LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_play_pause_layer, parent, false);

        ivPlayPause.setOnClickListener(v -> togglePlayPause());
        return ivPlayPause;
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
        final ImageView playButton = getView();
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
        final ImageView playButton = getView();
        if (playButton == null) return;
        VideoView videoView = videoView();
        if (videoView == null) return;
        if (videoView.getPlayScene() == PlayScene.SCENE_FULLSCREEN) {
            playButton.setImageDrawable(ResourcesCompat.getDrawable(playButton.getResources(),
                    R.drawable.vevod_play_pause_layer_fullscreen_ic_selector, null));
            final int size = (int) UIUtils.dip2Px(context(), 48);
            playButton.getLayoutParams().width = size;
            playButton.getLayoutParams().height = size;
            playButton.requestLayout();
        } else {
            playButton.setImageDrawable(ResourcesCompat.getDrawable(playButton.getResources(),
                    R.drawable.vevod_play_pause_layer_halfscreen_ic_selector, null));
            final int size = (int) UIUtils.dip2Px(context(), 40);
            playButton.getLayoutParams().width = size;
            playButton.getLayoutParams().height = size;
            playButton.requestLayout();
        }
    }

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK:
                if (player() == null) {
                    dismiss();
                }
                break;
        }

        switch (event.code()) {
            case PlayerEvent.State.STARTED:
            case PlayerEvent.State.PAUSED:
                syncState();
                break;
            case PlayerEvent.State.COMPLETED:
                syncState();
                dismiss();
                break;
            case PlayerEvent.State.STOPPED:
            case PlayerEvent.State.RELEASED:
                show();
                break;
            case PlayerEvent.State.ERROR:
            case PlayerEvent.Info.BUFFERING_END:
            case PlayerEvent.Info.BUFFERING_START:
                dismiss();
                break;
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

    protected boolean checkShow() {
        return true;
    }
}