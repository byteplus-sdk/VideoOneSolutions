// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;

public class InfoFrameInfoUpdate extends Event {
    @Player.FrameType
    public int frameType;
    public long pts;
    public long clockTime;

    public InfoFrameInfoUpdate() {
        super(PlayerEvent.Info.FRAME_INFO_UPDATE);
    }

    public InfoFrameInfoUpdate init(@Player.FrameType int frameType, long pts, long clockTime) {
        this.frameType = frameType;
        this.pts = pts;
        this.clockTime = clockTime;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        frameType = Player.FRAME_TYPE_UNKNOWN;
        pts = 0;
        clockTime = 0;
    }
}
