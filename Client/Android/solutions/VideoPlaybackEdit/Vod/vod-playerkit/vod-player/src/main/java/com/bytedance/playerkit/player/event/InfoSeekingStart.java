// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class InfoSeekingStart extends Event {

    public long from;
    public long to;

    public InfoSeekingStart() {
        super(PlayerEvent.Info.SEEKING_START);
    }

    public InfoSeekingStart init(long from, long seekTo) {
        this.from = from;
        this.to = seekTo;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        from = 0;
        to = 0;
    }
}
