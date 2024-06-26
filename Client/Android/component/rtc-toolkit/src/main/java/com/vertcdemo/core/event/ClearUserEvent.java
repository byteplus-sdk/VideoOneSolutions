// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

/**
 * User logged on other device, Kick this device out
 */
@RTSInform
public class ClearUserEvent {
    @SerializedName("room_id")
    public String roomId;
    @SerializedName("user_id")
    public String userId;

    @NonNull
    @Override
    public String toString() {
        return "ClearUserEvent{" +
                "roomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                '}';
    }
}
