// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.ktv.core.rts.annotation.FinishType;

@RTSInform
public class FinishLiveBroadcast {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("type")
    @FinishType
    public int type;

    @Override
    public String toString() {
        return "FinishLiveBroadcast{" +
                "requireRoomId='" + roomId + '\'' +
                ", type=" + type +
                '}';
    }
}
