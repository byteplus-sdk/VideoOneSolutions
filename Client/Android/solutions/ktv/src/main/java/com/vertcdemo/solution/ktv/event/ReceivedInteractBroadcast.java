// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.UserInfo;

public class ReceivedInteractBroadcast {

    @SerializedName("host_info")
    public UserInfo userInfo;
    @SerializedName("seat_id")
    public int seatId;

    @Override
    public String toString() {
        return "ReceivedInteractBroadcast{" +
                "userInfo=" + userInfo +
                ", seatId=" + seatId +
                '}';
    }
}
