// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.config.ICompleteAction;
import com.byteplus.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;

public class DramaVideoPlayerConfigLayer extends PlaybackEventLayer {
    public static DramaVideoPlayerConfigLayer loop() {
        return new DramaVideoPlayerConfigLayer(ICompleteAction.LOOP);
    }

    public static DramaVideoPlayerConfigLayer next() {
        return new DramaVideoPlayerConfigLayer(ICompleteAction.NEXT);
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
            boolean looping = mConfig == ICompleteAction.LOOP;
            player.setLooping(looping);
        }
    }
}
