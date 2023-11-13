// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class ActionSetLooping extends Event {

    public boolean isLooping;

    public ActionSetLooping() {
        super(PlayerEvent.Action.SET_LOOPING);
    }

    @Override
    public void recycle() {
        super.recycle();
        isLooping = false;
    }

    public ActionSetLooping init(boolean isLooping) {
        this.isLooping = isLooping;
        return this;
    }
}
