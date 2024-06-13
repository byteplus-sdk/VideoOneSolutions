// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.SubtitleText;
import com.byteplus.playerkit.utils.event.Event;

public class InfoSubtitleTextUpdate extends Event {
    public SubtitleText subtitleText;

    public InfoSubtitleTextUpdate() {
        super(PlayerEvent.Info.SUBTITLE_TEXT_UPDATE);
    }

    public InfoSubtitleTextUpdate init(SubtitleText subtitleText) {
        this.subtitleText = subtitleText;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();

        this.subtitleText = null;
    }
}
