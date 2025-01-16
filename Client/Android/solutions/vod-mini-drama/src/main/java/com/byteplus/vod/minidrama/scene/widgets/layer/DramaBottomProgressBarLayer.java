// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import static com.byteplus.vod.scenekit.ui.video.layer.Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.InfoBufferingUpdate;
import com.byteplus.playerkit.player.event.InfoProgressUpdate;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.minidrama.scene.widgets.MDMediaSeekBar;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.utils.ViewUtils;

public class DramaBottomProgressBarLayer extends BaseLayer {
    private MDMediaSeekBar mMediaSeekBar;

    public DramaBottomProgressBarLayer(MDMediaSeekBar mediaSeekBar) {
        mMediaSeekBar = mediaSeekBar;
        mMediaSeekBar.setTextVisibility(false);
        mMediaSeekBar.setOnSeekListener(new MDMediaSeekBar.OnUserSeekListener() {

            @Override
            public void onUserSeekStart(long startPosition) {
            }

            @Override
            public void onUserSeekPeeking(long peekPosition) {
                setPeekTimeProgress(peekPosition, true);
            }

            @Override
            public void onUserSeekStop(long startPosition, long seekToPosition) {
                dismissTimeProgressDialog();
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

        SeekBar seekBar = mMediaSeekBar.findViewById(R.id.seekBar);
        final int _12dp = (int) ViewUtils.dp2px(12);
        seekBar.setPadding(_12dp, 0, _12dp, 0);

        seekBar.setProgressDrawable(ResourcesCompat.getDrawable(seekBar.getResources(), R.drawable.vevod_mini_drama_bottom_progress_bar_layer_seekbar_track_material, null));
        seekBar.setIndeterminateDrawable(ResourcesCompat.getDrawable(seekBar.getResources(), R.drawable.vevod_mini_drama_bottom_progress_bar_layer_seekbar_track_material, null));

        mMediaSeekBar.setVisibility(View.GONE);
    }

    @Nullable
    @Override
    public String tag() {
        return "bottom_progress_bar";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        return null;
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    @Override
    public void requestDismiss(@NonNull String reason) {
        if (!TextUtils.equals(REQUEST_DISMISS_REASON_DIALOG_SHOW, reason)) {
            super.requestDismiss(reason);
        }
    }

    @Override
    public void show() {
        super.show();
        if (mMediaSeekBar != null && mMediaSeekBar.getVisibility() != View.VISIBLE) {
            mMediaSeekBar.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        if (mMediaSeekBar != null && mMediaSeekBar.getVisibility() == View.VISIBLE) {
            mMediaSeekBar.setVisibility(View.GONE);
        }
    }

    @Override
    public void hide() {
        super.hide();
        if (mMediaSeekBar != null && mMediaSeekBar.getVisibility() == View.VISIBLE) {
            mMediaSeekBar.setVisibility(View.GONE);
        }
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlaybackEvent.Action.START_PLAYBACK:
                    show();
                    if (player() == null) {
                        setProgress(0, 0, 0);
                    }
                    break;
                case PlaybackEvent.State.BIND_PLAYER:
                    if (player() != null) {
                        syncProgress();
                    }
                    break;
                case PlayerEvent.Action.START:
                    if (event.owner(Player.class).isPaused()) {
                        syncProgress();
                    }
                    break;
                case PlayerEvent.State.STARTED:
                case PlayerEvent.State.COMPLETED: {
                    syncProgress();
                    break;
                }
                case PlayerEvent.State.ERROR:
                case PlayerEvent.State.RELEASED: {
                    hide();
                    break;
                }
                case PlayerEvent.Info.VIDEO_RENDERING_START:
                    syncProgress();
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
        if (mMediaSeekBar != null) {
            if (duration >= 0) {
                mMediaSeekBar.setDuration(duration);
            }
            if (currentPosition >= 0) {
                mMediaSeekBar.setCurrentPosition(currentPosition);
            }
            if (bufferPercent >= 0) {
                mMediaSeekBar.setCachePercent(bufferPercent);
            }
        }
    }

    private void dismissTimeProgressDialog() {
        final VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return;

        final DramaTimeProgressDialogLayer dialogLayer = layerHost.findLayer(DramaTimeProgressDialogLayer.class);
        if (dialogLayer == null) return;

        if (!dialogLayer.isShowing()) return;

        dialogLayer.animateDismiss();
    }

    private void setPeekTimeProgress(long userPeekPosition, boolean showDialog) {
        final VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return;

        final DramaTimeProgressDialogLayer dialogLayer = layerHost.findLayer(DramaTimeProgressDialogLayer.class);
        if (dialogLayer == null) return;

        final Player player = player();
        long duration = player != null ? player.getDuration() : 0;

        if (duration <= 0) {
            final MediaSource mediaSource = dataSource();
            duration = mediaSource != null ? mediaSource.getDuration() : 0;
        }
        if (!dialogLayer.isShowing() && showDialog) {
            dialogLayer.animateShow(false);
        }
        dialogLayer.setCurrentPosition(userPeekPosition, duration);
    }
}
