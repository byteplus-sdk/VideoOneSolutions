// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.event;

/**
 * SDK reconnection into room event
 */
public class RTCReconnectToRoomEvent {

    public final String roomId;
    public final String uid;
    public final int state;
    public final String extraInfo;

    public RTCReconnectToRoomEvent(String roomId, String uid, int state, String extraInfo) {
        this.roomId = roomId;
        this.uid = uid;
        this.state = state;
        this.extraInfo = extraInfo;
    }
}
