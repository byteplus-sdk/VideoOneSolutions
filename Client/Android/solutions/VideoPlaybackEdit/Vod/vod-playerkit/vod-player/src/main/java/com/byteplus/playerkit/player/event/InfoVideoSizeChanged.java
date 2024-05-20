// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoVideoSizeChanged extends Event {

    public int videoWidth;
    public int videoHeight;

    public InfoVideoSizeChanged() {
        super(PlayerEvent.Info.VIDEO_SIZE_CHANGED);
    }

    public InfoVideoSizeChanged init(int videoWidth, int videoHeight) {
        this.videoWidth = videoWidth;
        this.videoHeight = videoHeight;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        videoWidth = 0;
        videoHeight = 0;
    }
}
