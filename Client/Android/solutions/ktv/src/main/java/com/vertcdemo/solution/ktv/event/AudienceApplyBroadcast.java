// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.UserInfo;

public class AudienceApplyBroadcast {

    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("seat_id")
    public int seatId;

    @NonNull
    @Override
    public String toString() {
        return "AudienceApplyBroadcast{" +
                "userInfo=" + userInfo +
                ", seatId=" + seatId +
                '}';
    }
}
