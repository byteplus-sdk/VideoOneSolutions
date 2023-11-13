// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Supplier;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.VideoLayer;
import com.bytedance.playerkit.utils.event.Dispatcher;

public class PlayerConfigLayer extends VideoLayer {
    @Nullable
    @Override
    public String tag() {
        return "player_config";
    }

    final Dispatcher.EventListener eventListener;

    public PlayerConfigLayer(@NonNull Supplier<Boolean> supplier) {
        eventListener = event -> {
            switch (event.code()) {
                case PlayerEvent.Action.PREPARE:
                    Player player = event.owner(Player.class);
                    player.setLooping(supplier.get());
                    break;
            }
        };
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        return null;
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(eventListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(eventListener);
    }
}
