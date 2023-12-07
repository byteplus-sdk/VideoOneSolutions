// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.ui.video.layer.base.PlaybackEventAnimateLayer;


public class PlayCompleteLayer extends PlaybackEventAnimateLayer {

    @Override
    public String tag() {
        return "play_complete";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View ivReplay = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_replay_layer, parent, false);
        ivReplay.setOnClickListener(v -> startPlayback());
        return ivReplay;
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK:
            case PlaybackEvent.Action.STOP_PLAYBACK:
                dismiss();
                break;
            case PlayerEvent.State.COMPLETED:
                Player player = event.owner(Player.class);
                if (!player.isLooping()) {
                    animateShow(false);
                }
                break;
            case PlayerEvent.State.STARTED:
            case PlayerEvent.Info.SEEKING_START: {
                dismiss();
                break;
            }
        }
    }
}
