// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.utils.event.Event;


public class ActionPrepare extends Event {

    public MediaSource mediaSource;

    public ActionPrepare() {
        super(PlayerEvent.Action.PREPARE);
    }

    public ActionPrepare init(MediaSource source) {
        this.mediaSource = source;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        mediaSource = null;
    }
}
