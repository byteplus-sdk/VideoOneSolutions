// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoVideoSARChanged extends Event {

    public int num;
    public int den;

    public InfoVideoSARChanged() {
        super(PlayerEvent.Info.VIDEO_SAR_CHANGED);
    }


    public InfoVideoSARChanged init(int num, int den) {
        this.num = num;
        this.den = den;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        num = 0;
        den = 0;
    }
}
