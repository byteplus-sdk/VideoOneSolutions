package com.byteplus.aichat.bean

import com.google.gson.annotations.SerializedName

class VoiceProvider(
    @SerializedName("provider_name")
    val name: String,
    @SerializedName("pic")
    val icon: String,
    @SerializedName("list")
    val voices: List<VoiceType>
)

class VoiceType(
    @SerializedName("name")
    val name: String,
    @SerializedName("pic")
    val icon: String,
    @SerializedName("desc")
    val desc: String,
    @SerializedName("voice")
    val audition: String
)

class Voice(
    val provider: VoiceProvider, val voiceType: VoiceType
) {
    val providerName: String
        get() = provider.name

    val name: String
        get() = voiceType.name

    val icon: String
        get() = voiceType.icon

    val audition: String
        get() = voiceType.audition

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Voice) return false

        return providerName == other.providerName && name == other.name
    }
}

val EmptyVoice = Voice(
    VoiceProvider("", "", emptyList()),
    VoiceType("", "", "", "")
)