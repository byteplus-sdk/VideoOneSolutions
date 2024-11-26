// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.chat.annotation.GiftType;
import com.vertcdemo.solution.interactivelive.core.annotation.MessageType;

public class MessageBody {
    @MessageType
    @SerializedName("type")
    public int type;

    @SerializedName("content")
    public String content;

    @GiftType
    @SerializedName("giftType")
    public int giftType;

    @SerializedName("count")
    public int count;

    public MessageBody() {
    }

    public MessageBody(@MessageType int type) {
        this.type = type;
    }

    public MessageBody(@MessageType int type, @GiftType int giftType) {
        this.type = type;
        this.giftType = giftType;
    }

    public static MessageBody createMessage(String content) {
        final MessageBody body = new MessageBody();
        body.content = content;
        body.type = MessageType.MSG;
        return body;
    }

    public static MessageBody createGift(@GiftType int giftType) {
        final MessageBody body = new MessageBody();
        body.type = MessageType.GIFT;
        body.giftType = giftType;
        return body;
    }

    public static final MessageBody LIKE = new MessageBody(MessageType.LIKE);

    public static final MessageBody GIFT_LIKE = new MessageBody(MessageType.GIFT, GiftType.LIKE);
    public static final MessageBody GIFT_SUGAR = new MessageBody(MessageType.GIFT, GiftType.SUGAR);
    public static final MessageBody GIFT_DIAMOND = new MessageBody(MessageType.GIFT, GiftType.DIAMOND);
    public static final MessageBody GIFT_FIREWORKS = new MessageBody(MessageType.GIFT, GiftType.FIREWORKS);
}
