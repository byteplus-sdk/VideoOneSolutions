package com.byteplus.aichat.bean

import com.google.gson.annotations.SerializedName

class AiConfigResponse(
    @SerializedName("prompt")
    val prompt: String,
    @SerializedName("welcome_speech")
    val welcomeSpeech: String,

    @SerializedName("realtime_voice_provider_list")
    val realtimeVoiceProviders: List<VoiceProvider>,
    @SerializedName("flexible_voice_provider_list")
    val flexibleVoiceProviders: List<VoiceProvider>,

    @SerializedName("llm_provider_list")
    val llms: List<LLM>,
    @SerializedName("asr_provider_list")
    val asrs: List<ASR>,

    @SerializedName("preset_questions")
    val questions: List<String>,
)