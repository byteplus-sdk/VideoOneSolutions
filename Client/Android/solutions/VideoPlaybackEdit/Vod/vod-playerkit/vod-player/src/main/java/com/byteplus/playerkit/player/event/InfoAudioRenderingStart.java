// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoAudioRenderingStart extends Event {

    public InfoAudioRenderingStart() {
        super(PlayerEvent.Info.AUDIO_RENDERING_START);
    }
}
