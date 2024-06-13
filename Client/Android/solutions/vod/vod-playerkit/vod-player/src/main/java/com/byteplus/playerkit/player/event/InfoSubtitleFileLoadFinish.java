// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;

public class InfoSubtitleFileLoadFinish extends Event {
    public int success;
    public String info;

    public InfoSubtitleFileLoadFinish() {
        super(PlayerEvent.Info.SUBTITLE_FILE_LOAD_FINISH);
    }


    public InfoSubtitleFileLoadFinish init(int success, String info) {
        this.success = success;
        this.info = info;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.success = 0;
        this.info = null;
    }
}
