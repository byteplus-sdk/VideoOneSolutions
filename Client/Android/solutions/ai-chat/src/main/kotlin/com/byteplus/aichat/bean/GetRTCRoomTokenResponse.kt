package com.byteplus.aichat.bean

import com.google.gson.annotations.SerializedName

class GetRTCRoomTokenResponse(
    @SerializedName("Token")
    val token: String,
    @SerializedName("ExpiredAt")
    val expiredAt: Long?
)
