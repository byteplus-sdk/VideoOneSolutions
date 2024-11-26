// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.chat.bean.IGiftEvent;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;

public class MessageEvent implements IGiftEvent {
    @SerializedName("user")
    public LiveUserInfo user;

    @SerializedName("message")
    public String message;

    private transient MessageBody body;

    public MessageBody getBody() {
        if (body == null) {
            body = GsonUtils.gson().fromJson(message, MessageBody.class);
        }
        return body;
    }

    @Override
    public int getGiftType() {
        return getBody().giftType;
    }

    @Override
    public String getUserId() {
        return user.userId;
    }

    @Override
    public String getUserName() {
        return user.userName;
    }

    @Override
    public int getCount() {
        return getBody().count;
    }
}
