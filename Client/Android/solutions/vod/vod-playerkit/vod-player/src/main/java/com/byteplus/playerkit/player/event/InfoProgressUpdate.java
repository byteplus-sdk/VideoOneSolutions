// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoProgressUpdate extends Event {

    public long currentPosition;
    public long duration;

    public InfoProgressUpdate() {
        super(PlayerEvent.Info.PROGRESS_UPDATE);
    }

    public InfoProgressUpdate init(long currentPosition, long duration) {
        this.currentPosition = currentPosition;
        this.duration = duration;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        currentPosition = 0;
        duration = 0;
    }
}
