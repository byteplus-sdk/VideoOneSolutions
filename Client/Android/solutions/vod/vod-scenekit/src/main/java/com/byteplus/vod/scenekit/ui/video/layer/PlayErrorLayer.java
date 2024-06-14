// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.PlayerException;
import com.byteplus.playerkit.player.event.StateError;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;

public class PlayErrorLayer extends BaseLayer {

    private PlayerException mException;

    @Override
    public String tag() {
        return "play_error";
    }

    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View textView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_play_error_layer, parent, false);
        textView.setOnClickListener(v -> startPlayback());
        return textView;
    }

    @Override
    public void show() {
        super.show();
        TextView textView = getView();
        if (mException != null && textView != null) {
            textView.setText(textView.getResources().getString(R.string.vevod_play_error_text, mException.toString()));
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        mException = null;
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
                case PlaybackEvent.Action.START_PLAYBACK:
                case PlaybackEvent.Action.STOP_PLAYBACK:
                    dismiss();
                    break;
                case PlayerEvent.State.ERROR: {
                    PlayErrorLayer.this.mException = event.cast(StateError.class).e;
                    show();
                    break;
                }
            }
        }
    };
}
