// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.annotation.CompleteAction;
import com.byteplus.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;

public class DramaVideoPlayerConfigLayer extends PlaybackEventLayer {
    public static DramaVideoPlayerConfigLayer loop() {
        return new DramaVideoPlayerConfigLayer(CompleteAction.LOOP);
    }

    public static DramaVideoPlayerConfigLayer next() {
        return new DramaVideoPlayerConfigLayer(CompleteAction.NEXT);
    }

    private final int mConfig;

    public DramaVideoPlayerConfigLayer(int config) {
        this.mConfig = config;
    }

    @Nullable
    @Override
    public String tag() {
        return "drama-player-config-layer";
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        if (event.code() == PlayerEvent.Action.PREPARE) {
            Player player = event.owner(Player.class);
            boolean looping = mConfig == CompleteAction.LOOP;
            player.setLooping(looping);
        }
    }
}
