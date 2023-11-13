// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class InfoBufferingUpdate extends Event {

    public int percent;

    public InfoBufferingUpdate() {
        super(PlayerEvent.Info.BUFFERING_UPDATE);
    }

    public InfoBufferingUpdate init(int percent) {
        this.percent = percent;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        percent = 0;
    }
}
