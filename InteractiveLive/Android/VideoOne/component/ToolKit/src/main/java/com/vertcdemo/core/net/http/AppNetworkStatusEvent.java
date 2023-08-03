// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.http;


/**
 * Network state connection state change event
 */
public class AppNetworkStatusEvent {

    public final @AppNetworkStatus int status;

    public AppNetworkStatusEvent(int status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "AppNetworkStatusEvent{" +
                "status=" + status +
                '}';
    }
}
