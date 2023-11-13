// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.PlayerException;
import com.bytedance.playerkit.utils.event.Event;


public class StateError extends Event {
    public PlayerException e;

    public StateError() {
        super(PlayerEvent.State.ERROR);
    }

    public StateError init(PlayerException e) {
        this.e = e;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        e = null;
    }
}
