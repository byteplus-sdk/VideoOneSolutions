// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;

public class InfoVideoRenderingStartBeforeStart extends Event {
    public InfoVideoRenderingStartBeforeStart() {
        super(PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START);
    }
}
