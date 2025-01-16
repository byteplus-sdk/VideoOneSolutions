// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.utils.event.Event;

public class InfoSubtitleWillChange extends Event {

    public Subtitle current;
    public Subtitle target;

    public InfoSubtitleWillChange() {
        super(PlayerEvent.Info.SUBTITLE_WILL_CHANGE);
    }

    public InfoSubtitleWillChange init(Subtitle current, Subtitle target) {
        this.current = current;
        this.target = target;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.current = null;
        this.target = null;
    }
}
