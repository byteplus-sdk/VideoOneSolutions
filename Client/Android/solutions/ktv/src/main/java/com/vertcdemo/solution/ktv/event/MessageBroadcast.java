// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.ktv.bean.UserInfo;

@RTSInform
public class MessageBroadcast {
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("message")
    public String message;

    @Override
    public String toString() {
        return "ChatMessageEvent{" +
                "userInfo=" + userInfo +
                ", message='" + message + '\'' +
                '}';
    }
}
