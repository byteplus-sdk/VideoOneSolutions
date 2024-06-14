// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import android.view.Surface;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class ActionSetSurface extends Event {

    public Surface surface;

    public ActionSetSurface() {
        super(PlayerEvent.Action.SET_SURFACE);
    }

    public ActionSetSurface init(Surface surface) {
        this.surface = surface;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        surface = null;
    }
}
