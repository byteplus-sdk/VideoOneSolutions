// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.utils.event.Event;

public class InfoSubtitleChanged extends Event {

    public Subtitle pre;
    public Subtitle current;


    public InfoSubtitleChanged() {
        super(PlayerEvent.Info.SUBTITLE_CHANGED);
    }

    public InfoSubtitleChanged init(Subtitle pre, Subtitle current) {
        this.pre = pre;
        this.current = current;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.pre = null;
        this.current = null;
    }
}
