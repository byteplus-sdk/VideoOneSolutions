// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;

/**
 * 来自业务服务端消息事件
 */
public class MessageInform {
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
