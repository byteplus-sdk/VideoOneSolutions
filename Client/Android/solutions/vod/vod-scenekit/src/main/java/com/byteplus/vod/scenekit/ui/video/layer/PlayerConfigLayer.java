// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.config.ICompleteAction;
import com.byteplus.vod.scenekit.ui.video.layer.base.PlaybackEventLayer;

public class PlayerConfigLayer extends PlaybackEventLayer {
    @Nullable
    @Override
    public String tag() {
        return "player_config";
    }

    public PlayerConfigLayer() {
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        if (event.code() == PlayerEvent.Action.PREPARE) {
            Player player = event.owner(Player.class);

            ICompleteAction config = getConfig();
            boolean looping = config != null && config.completeAction() == ICompleteAction.LOOP;
            player.setLooping(looping);
        }
    }
}
