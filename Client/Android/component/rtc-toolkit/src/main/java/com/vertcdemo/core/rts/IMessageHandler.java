// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.rts;

public interface IMessageHandler {
    String UID_SERVER = "server";

    void onMessageReceived(String uid, String message);
}
