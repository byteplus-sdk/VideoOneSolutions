// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;

@RTSInform
public class MessageEvent {
    @SerializedName("user")
    public LiveUserInfo user;

    @SerializedName("message")
    public String message;

    public MessageBody getBody() {
        return GsonUtils.gson().fromJson(message, MessageBody.class);
    }
}
