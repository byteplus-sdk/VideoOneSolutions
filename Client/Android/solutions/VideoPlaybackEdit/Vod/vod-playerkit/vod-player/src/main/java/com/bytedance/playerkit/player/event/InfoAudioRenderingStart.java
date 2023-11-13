// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class InfoAudioRenderingStart extends Event {

    public InfoAudioRenderingStart() {
        super(PlayerEvent.Info.AUDIO_RENDERING_START);
    }
}
