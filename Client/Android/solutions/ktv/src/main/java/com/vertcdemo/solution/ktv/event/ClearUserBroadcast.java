// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

@RTSInform
public class ClearUserBroadcast {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("user_id")
    public String userId;

    @Override
    public String toString() {
        return "ClearUserBroadcast{" +
                "requireRoomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                '}';
    }
}
