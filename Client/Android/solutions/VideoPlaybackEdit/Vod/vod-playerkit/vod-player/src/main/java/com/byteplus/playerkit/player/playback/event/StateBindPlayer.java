// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback.event;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.utils.event.Event;


public class StateBindPlayer extends Event {

    public Player player;

    public StateBindPlayer() {
        super(PlaybackEvent.State.BIND_PLAYER);
    }

    public StateBindPlayer init(Player player) {
        this.player = player;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.player = null;
    }
}
