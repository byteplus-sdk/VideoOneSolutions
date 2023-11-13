// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.playback.event;

import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.utils.event.Event;


public class ActionStartPlayback extends Event {

    public ActionStartPlayback() {
        super(PlaybackEvent.Action.START_PLAYBACK);
    }
}
