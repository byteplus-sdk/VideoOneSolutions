// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback.event;

import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.utils.event.Event;


public class ActionStartPlayback extends Event {

    public ActionStartPlayback() {
        super(PlaybackEvent.Action.START_PLAYBACK);
    }
}
