// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class InfoBufferingStart extends Event {

    public int bufferId;

    public InfoBufferingStart() {
        super(PlayerEvent.Info.BUFFERING_START);
    }

    public InfoBufferingStart init(int bufferId) {
        this.bufferId = bufferId;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        bufferId = 0;
    }
}
