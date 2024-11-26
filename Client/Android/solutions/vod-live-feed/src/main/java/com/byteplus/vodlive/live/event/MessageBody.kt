package com.byteplus.vodlive.live.event

import com.byteplus.vodlive.annotation.MessageType
import com.google.gson.annotations.SerializedName
import com.vertcdemo.core.chat.annotation.GiftType

val MSG_LIKE: MessageBody = MessageBody(type = MessageType.LIKE)
val MSG_GIFT_LIKE = MessageBody(type = MessageType.GIFT, giftType = GiftType.LIKE)
val MSG_GIFT_SUGAR = MessageBody(type = MessageType.GIFT, giftType = GiftType.SUGAR)
val MSG_GIFT_DIAMOND = MessageBody(type = MessageType.GIFT, giftType = GiftType.DIAMOND)
val MSG_GIFT_FIREWORKS = MessageBody(type = MessageType.GIFT, giftType = GiftType.FIREWORKS)

class MessageBody(
    @MessageType
    @SerializedName("type")
    var type: Int = MessageType.MSG,

    @SerializedName("content")
    var content: String? = "",

    @GiftType
    @SerializedName("giftType")
    var giftType: Int = 0,

    @SerializedName("count")
    var count: Int = 0
)