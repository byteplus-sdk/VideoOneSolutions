package com.byteplus.vodlive.network.model

import com.google.gson.annotations.SerializedName

class SwitchLiveRoomResult(
    @SerializedName("audience_count")
    val audienceCount: Int,
) {
    override fun toString(): String {
        return "SwitchLiveRoomResult(audienceCount=$audienceCount)"
    }
}

class SendMessageResult(
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("message")
    val message: String,
)