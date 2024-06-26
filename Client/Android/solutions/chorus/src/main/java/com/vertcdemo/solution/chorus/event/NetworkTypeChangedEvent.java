// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

public class NetworkTypeChangedEvent {
    public final int type;

    public NetworkTypeChangedEvent(int type) {
        this.type = type;
    }
}
