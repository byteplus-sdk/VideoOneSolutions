package com.byteplus.aichat.settings

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.byteplus.aichat.bean.ASR
import com.byteplus.aichat.bean.AiConfigResponse
import com.byteplus.aichat.bean.EmptyVoice
import com.byteplus.aichat.bean.LLM
import com.byteplus.aichat.bean.Voice
import com.byteplus.aichat.bean.VoiceProvider

enum class IntegrationMode {
    REALTIME,
    FLEXIBLE
}

class SettingsViewModel : ViewModel() {
    val integrationMode = MutableLiveData(MemoryConfig.mode)

    fun setIntegrationMode(mode: IntegrationMode) {
        integrationMode.value = mode
    }

    val welcomeSpeech = MutableLiveData(MemoryConfig.welcomeSpeech)

    fun setWelcomeSpeech(value: String) {
        welcomeSpeech.value = Option<String>(value, Source.USER)
    }

    val prompt = MutableLiveData(MemoryConfig.prompt)

    fun setPrompt(value: String) {
        prompt.value = Option<String>(value, Source.USER)
    }

    var realtimeVoiceProviders: List<VoiceProvider> = emptyList()
        private set
    val voiceTypeRealtime = MutableLiveData(MemoryConfig.voiceTypeRealtime)

    var flexibleVoiceProviders: List<VoiceProvider> = emptyList()
        private set
    val voiceTypeFlexible = MutableLiveData(MemoryConfig.voiceTypeFlexible)

    var llms: List<LLM> = emptyList()
        private set
    val llmModel = MutableLiveData(MemoryConfig.llmModel)

    var asrs: List<ASR> = emptyList()
        private set

    val asrModel = MutableLiveData(MemoryConfig.asrModel)

    var questions: List<String> = emptyList()
        private set

    fun updateAiConfig(config: AiConfigResponse) {
        questions = config.questions

        if (welcomeSpeech.value?.isUserChanged != true) {
            welcomeSpeech.postValue(Option(config.welcomeSpeech))
        }

        if (prompt.value?.isUserChanged != true) {
            prompt.postValue(Option(config.prompt))
        }

        updateVoiceProviders(config.realtimeVoiceProviders, voiceTypeRealtime) { providers ->
            this.realtimeVoiceProviders = providers
        }

        updateVoiceProviders(config.flexibleVoiceProviders, voiceTypeFlexible) { providers ->
            this.flexibleVoiceProviders = providers
        }
        updateASRModel(config.asrs)
        updateLLMModel(config.llms)
    }

    private fun updateVoiceProviders(
        providers: List<VoiceProvider>,
        currentOption: MutableLiveData<Option<Voice>>,
        block: (providers: List<VoiceProvider>) -> Unit
    ) {
        assert(providers.isNotEmpty()) {
            "providers is empty"
        }

        val voices = providers.flatMap { provider ->
            provider.voices.map { voice -> Voice(provider, voice) }
        }

        assert(voices.isNotEmpty()) {
            "voices in providers is empty"
        }

        block(providers)

        val currentVoice = currentOption.value?.value
        if (currentVoice == null) {
            voices.first().let {
                currentOption.postValue(Option(it))
            }
        } else {
            // Check if valid, resign if not found
            val found = if (currentOption.value?.isUserChanged == true) {
                voices.find {
                    it.voiceType.name == currentVoice.voiceType.name
                            && it.provider.name == currentVoice.provider.name
                }
            } else {
                // force reset to first item
                null
            }

            if (found == null) {
                voices.first().let {
                    currentOption.postValue(Option(it))
                }
            }
        }
    }

    private fun updateLLMModel(llms: List<LLM>) {
        assert(llms.isNotEmpty()) {
            "llm models is empty"
        }

        this.llms = llms

        val currentLLM = llmModel.value?.value ?: ""
        if (currentLLM.isEmpty()) {
            llms.first().let {
                llmModel.postValue(Option(it.name))
            }
        } else {
            // Check if valid, resign if not found
            val found = if (llmModel.value?.isUserChanged == true) {
                llms.find { it.name == currentLLM }
            } else {
                // force reset to first item
                null
            }

            if (found == null) {
                llms.first().let {
                    llmModel.postValue(Option(it.name))
                }
            }
        }
    }

    private fun updateASRModel(asrs: List<ASR>) {
        assert(asrs.isNotEmpty()) {
            "llm models is empty"
        }

        this.asrs = asrs

        val currentASR = asrModel.value?.value ?: ""
        if (currentASR.isEmpty()) {
            asrs.first().let {
                asrModel.postValue(Option(it.name))
            }
        } else {
            // Check if valid, resign if not found
            val found = if (asrModel.value?.isUserChanged == true) {
                asrs.find { it.name == currentASR }
            } else {
                // force reset to first item
                null
            }

            if (found == null) {
                asrs.first().let {
                    asrModel.postValue(Option(it.name))
                }
            }
        }
    }

    override fun onCleared() {
        // save to memory
        MemoryConfig.mode = integrationMode.value!!

        welcomeSpeech.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.welcomeSpeech = value
            }
        }

        prompt.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.prompt = value
            }
        }

        voiceTypeRealtime.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.voiceTypeRealtime = value
            }
        }

        voiceTypeFlexible.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.voiceTypeFlexible = value
            }
        }

        llmModel.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.llmModel = value
            }
        }

        asrModel.value?.let { value ->
            if (value.isUserChanged) {
                MemoryConfig.asrModel = value
            }
        }
    }
}

object MemoryConfig {
    var mode = IntegrationMode.REALTIME

    var welcomeSpeech = OptionEmpty
    var prompt = OptionEmpty

    var voiceTypeRealtime = Option(EmptyVoice)

    var voiceTypeFlexible = Option(EmptyVoice)
    var llmModel = OptionEmpty
    var asrModel = OptionEmpty
}