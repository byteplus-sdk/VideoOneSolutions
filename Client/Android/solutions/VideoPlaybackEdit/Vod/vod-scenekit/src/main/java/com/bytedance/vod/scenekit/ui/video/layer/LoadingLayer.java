// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;

public class LoadingLayer extends AnimateLayer {

    private static Handler mHandler;

    public LoadingLayer() {
        if (mHandler == null) mHandler = new Handler();
    }

    @Override
    public String tag() {
        return "loading";
    }

    @Override
    protected View createView(@NonNull ViewGroup parent) {
        return LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_loading_layer, parent, false);
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
                case PlayerEvent.Action.PREPARE:
                case PlayerEvent.Action.START:
                case PlayerEvent.Info.BUFFERING_START: {
                    showOpt();
                    break;
                }
                case PlayerEvent.Info.BUFFERING_END:
                case PlayerEvent.State.COMPLETED:
                case PlayerEvent.State.ERROR:
                case PlayerEvent.Action.PAUSE:
                case PlayerEvent.Action.STOP:
                case PlaybackEvent.Action.STOP_PLAYBACK:
                case PlayerEvent.Action.RELEASE: {
                    dismiss();
                    break;
                }
                case PlayerEvent.Action.SET_SURFACE: {
                    Player player = event.owner(Player.class);
                    if (player.isBuffering()) {
                        showOpt();
                    } else if (player.isPreparing()) {
                        showOpt();
                    } else {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.Info.VIDEO_RENDERING_START:
                case PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START:
                case PlayerEvent.State.STARTED: {
                    Player player = event.owner(Player.class);
                    if (player.isBuffering()) {
                        showOpt();
                    } else {
                        dismiss();
                    }
                    break;
                }
            }
        }
    };

    @Override
    public void dismiss() {
        super.dismiss();
        mHandler.removeCallbacks(mShowRunnable);
    }

    private void showOpt() {
        mHandler.removeCallbacks(mShowRunnable);
        mHandler.postDelayed(mShowRunnable, 1000);
    }

    private final Runnable mShowRunnable = new Runnable() {
        @Override
        public void run() {
            animateShow(false);
        }
    };
}
