// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.utils.event.Event;

import java.util.List;

public class InfoSubtitleInfoReady extends Event {

    public List<Subtitle> subtitles;

    public InfoSubtitleInfoReady() {
        super(PlayerEvent.Info.SUBTITLE_LIST_INFO_READY);
    }

    public InfoSubtitleInfoReady init(List<Subtitle> subtitles) {
        this.subtitles = subtitles;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();

        subtitles = null;
    }
}
