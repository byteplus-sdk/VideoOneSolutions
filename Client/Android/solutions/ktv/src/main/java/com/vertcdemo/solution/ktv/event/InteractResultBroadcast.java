// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.bean.UserInfo;

public class InteractResultBroadcast {

    @SerializedName("reply")
    @ReplyType
    public int reply;
    @SerializedName("user_info")
    public UserInfo userInfo;

    @Override
    public String toString() {
        return "InteractResultBroadcast{" +
                "reply=" + reply +
                ", userInfo=" + userInfo +
                '}';
    }
}
