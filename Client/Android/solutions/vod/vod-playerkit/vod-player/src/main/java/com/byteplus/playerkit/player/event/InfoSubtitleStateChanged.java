// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;

public class InfoSubtitleStateChanged extends Event {

    public boolean enabled;

    public InfoSubtitleStateChanged() {
        super(PlayerEvent.Info.SUBTITLE_STATE_CHANGED);
    }

    public InfoSubtitleStateChanged init(boolean enabled) {
        this.enabled = enabled;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        enabled = false;
    }
}
