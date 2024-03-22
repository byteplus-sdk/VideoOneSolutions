// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

public class JoinRTSRoomErrorEvent {
    public final int errorCode;
    public final String message;
    public final boolean isReconnect;

    public JoinRTSRoomErrorEvent(int errorCode, String message) {
        this(errorCode, message, false);
    }

    public JoinRTSRoomErrorEvent(int errorCode, String message, boolean isReconnect) {
        this.errorCode = errorCode;
        this.message = message;
        this.isReconnect = isReconnect;
    }
}
