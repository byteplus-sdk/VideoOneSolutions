// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

public class RTCUserJoinEvent {
    public String userId;

    public RTCUserJoinEvent(String userId) {
        this.userId = userId;
    }
}
