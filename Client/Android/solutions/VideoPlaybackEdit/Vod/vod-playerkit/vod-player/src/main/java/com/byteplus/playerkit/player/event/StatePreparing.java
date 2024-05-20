// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class StatePreparing extends Event {
    public StatePreparing() {
        super(PlayerEvent.State.PREPARING);
    }
}
