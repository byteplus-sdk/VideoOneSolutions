package com.byteplus.aichat.bean

import com.google.gson.annotations.SerializedName

class LLM(
    @SerializedName("name")
    val name: String,
    @SerializedName("pic")
    val icon: String,
)