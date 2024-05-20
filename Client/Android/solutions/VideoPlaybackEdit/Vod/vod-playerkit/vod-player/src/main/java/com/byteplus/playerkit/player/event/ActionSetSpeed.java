// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class ActionSetSpeed extends Event {
    public float speed;

    public ActionSetSpeed() {
        super(PlayerEvent.Action.SET_SPEED);
    }

    @Override
    public void recycle() {
        super.recycle();
        speed = 0;
    }

    public ActionSetSpeed init(float speed) {
        this.speed = speed;
        return this;
    }
}
