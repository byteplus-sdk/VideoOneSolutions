// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.content.res.Configuration;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.InfoBufferingUpdate;
import com.byteplus.playerkit.player.event.InfoProgressUpdate;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.widgets.MediaSeekBar;

public class SimpleProgressBarLayer extends AnimateLayer {

    protected MediaSeekBar mSeekBar;

    protected boolean mDismissWhenPaused;

    public SimpleProgressBarLayer() {
        this(true);
    }

    public SimpleProgressBarLayer(boolean dismissWhenPaused) {
        mDismissWhenPaused = dismissWhenPaused;
    }

    @Override
    public String tag() {
        return "simple_progress";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_simple_progress_layer, parent, false);
        mSeekBar = view.findViewById(R.id.mediaSeekBar);
        mSeekBar.setOnSeekListener(new MediaSeekBar.OnUserSeekListener() {

            @Override
            public void onUserSeekStart(long startPosition) {

            }

            @Override
            public void onUserSeekPeeking(long peekPosition) {

            }

            @Override
            public void onUserSeekStop(long startPosition, long seekToPosition) {
                final Player player = player();
                if (player == null) return;

                if (player.isInPlaybackState()) {
                    if (player.isCompleted()) {
                        player.start();
                        player.seekTo(seekToPosition);
                    } else {
                        player.seekTo(seekToPosition);
                    }
                }
            }
        });
        return view;
    }


    private void syncProgress() {
        final PlaybackController controller = this.controller();
        if (controller != null) {
            final Player player = controller.player();
            if (player != null) {
                if (player.isInPlaybackState()) {
                    setProgress(player.getCurrentPosition(), player.getDuration(), player.getBufferedPercentage());
                }
            }
        }
    }

    private void setProgress(long currentPosition, long duration, int bufferPercent) {
        if (mSeekBar != null) {
            if (duration >= 0) {
                mSeekBar.setDuration(duration);
            }
            if (currentPosition >= 0) {
                mSeekBar.setCurrentPosition(currentPosition);
            }
            if (bufferPercent >= 0) {
                mSeekBar.setCachePercent(bufferPercent);
            }
        }
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
        dismiss();
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlayerEvent.Action.START:
                    if (event.owner(Player.class).isPaused()) {
                        animateShow(false);
                    }
                    break;
                case PlayerEvent.State.STARTED: {
                    syncProgress();
                    break;
                }
                case PlayerEvent.State.COMPLETED: {
                    syncProgress();
                    Player player = player();
                    if (player != null && !player.isLooping()) {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.State.PAUSED: {
                    if (mDismissWhenPaused) {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.State.ERROR:
                case PlayerEvent.State.STOPPED:
                case PlayerEvent.State.RELEASED: {
                    dismiss();
                    break;
                }
                case PlayerEvent.Info.VIDEO_RENDERING_START:
                    animateShow(false);
                    break;
                case PlayerEvent.Info.PROGRESS_UPDATE: {
                    InfoProgressUpdate e = event.cast(InfoProgressUpdate.class);
                    setProgress(e.currentPosition, e.duration, -1);
                    break;
                }
                case PlayerEvent.Info.BUFFERING_UPDATE: {
                    InfoBufferingUpdate e = event.cast(InfoBufferingUpdate.class);
                    setProgress(-1, -1, e.percent);
                    break;
                }
            }
        }
    };

    @Override
    public void show() {
        super.show();
        syncProgress();
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        VideoView videoView = videoView();
        PlaybackController playbackController =videoView == null ? null : videoView.controller();
        if (isInPictureInPictureMode) {
            if (playbackController != null) {
                playbackController.removePlaybackListener(mPlaybackListener);
            }
            dismiss();
        } else {
            if (playbackController != null) {
                playbackController.addPlaybackListener(mPlaybackListener);
            }
            show();
        }
    }
}
