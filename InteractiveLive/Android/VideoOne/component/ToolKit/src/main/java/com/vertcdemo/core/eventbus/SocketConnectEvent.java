// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus;

public class SocketConnectEvent {
    public ConnectStatus status;

    public SocketConnectEvent(ConnectStatus status) {
        this.status = status;
    }

    public enum ConnectStatus {
        CONNECTED,
        CONNECTING,
        RECONNECTED,
        DISCONNECTED
    }
}
