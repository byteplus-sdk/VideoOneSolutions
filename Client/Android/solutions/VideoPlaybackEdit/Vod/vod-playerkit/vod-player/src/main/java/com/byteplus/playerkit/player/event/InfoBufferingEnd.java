// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoBufferingEnd extends Event {

    public int bufferId;

    public InfoBufferingEnd() {
        super(PlayerEvent.Info.BUFFERING_END);
    }

    public InfoBufferingEnd init(int bufferId) {
        this.bufferId = bufferId;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        bufferId = 0;
    }
}
