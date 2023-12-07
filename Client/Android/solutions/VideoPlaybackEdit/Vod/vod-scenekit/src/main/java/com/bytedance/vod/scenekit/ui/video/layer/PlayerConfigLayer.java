// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Supplier;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;

public class PlayerConfigLayer extends PlaybackEventLayer {
    @Nullable
    @Override
    public String tag() {
        return "player_config";
    }

    @NonNull
    final Supplier<Boolean> mLoopingSupplier;

    public PlayerConfigLayer(@NonNull Supplier<Boolean> supplier) {
        mLoopingSupplier = supplier;
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        if (event.code() == PlayerEvent.Action.PREPARE) {
            Player player = event.owner(Player.class);
            player.setLooping(mLoopingSupplier.get());
        }
    }
}
