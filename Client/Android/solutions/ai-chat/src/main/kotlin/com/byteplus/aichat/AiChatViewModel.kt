package com.byteplus.aichat

import android.app.Application
import android.os.SystemClock
import android.util.Log
import androidx.fragment.app.Fragment
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import androidx.lifecycle.viewmodel.ViewModelInitializer
import androidx.navigation.fragment.findNavController
import com.byteplus.aichat.network.AiChatService
import com.byteplus.aichat.settings.IntegrationMode
import com.byteplus.aichat.settings.SettingsViewModel
import com.ss.bytertc.engine.RTCRoom
import com.ss.bytertc.engine.RTCRoomConfig
import com.ss.bytertc.engine.RTCVideo
import com.ss.bytertc.engine.UserInfo
import com.ss.bytertc.engine.data.AudioPropertiesConfig
import com.ss.bytertc.engine.data.RemoteAudioState
import com.ss.bytertc.engine.data.RemoteAudioStateChangeReason
import com.ss.bytertc.engine.data.RemoteStreamKey
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler
import com.ss.bytertc.engine.type.ChannelProfile
import com.ss.bytertc.engine.type.MediaStreamType
import com.ss.bytertc.engine.type.StreamRemoveReason
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.http.bean.RTCAppInfo
import com.vertcdemo.core.net.SolutionRetrofit
import com.vertcdemo.ui.CenteredToast
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

/**
 *  trial time duration 20 minutes
 */
const val TRIAL_TIME_SECONDS = 1200L

private const val TAG = "AiChatVM"

private const val APP_KEY = com.vertcdemo.rtc.toolkit.BuildConfig.APP_KEY
private const val APP_ID = com.vertcdemo.rtc.toolkit.BuildConfig.APP_KEY

class AiChatViewModel(
    private val context: Application,
    private val fragment: Fragment,
    private val rtcAppInfo: RTCAppInfo,
    private val settings: SettingsViewModel
) : ViewModel() {

    private val chatApi = SolutionRetrofit.getApi(AiChatService::class.java)

    private val videoHandler: IRTCVideoEventHandler = object : IRTCVideoEventHandler() {
        override fun onRemoteAudioStateChanged(
            key: RemoteStreamKey?,
            state: RemoteAudioState?,
            reason: RemoteAudioStateChangeReason?
        ) {
            Log.d(
                TAG, "onRemoteAudioStateChanged. state : "
                    .plus(state).plus(" ,reason : ")
                    .plus(reason).plus(" ,user_id : ")
                    .plus(key?.userId)
            )
        }

        override fun onActiveSpeaker(roomId: String?, uid: String?) {
            // Log.d(TAG, String.format("onActiveSpeaker: %s,%s",roomId, uid))
            val currentTime = SystemClock.uptimeMillis()
            if (lastKeepAiAgentQuestionsTime < 1) {
                lastKeepAiAgentQuestionsTime = currentTime;
            }
            if (currentTime - lastKeepAiAgentQuestionsTime < 2000) { // keep ai agent questions 2 seconds
                if (_state.value != AiState.PREPARED) {
                    switchState(AiState.PREPARED)
                }
                return
            }
            val userId: String = SolutionDataManager.userId!!
            if (userId == uid) { // local is active speaker
                if (currentTime - lastLocalSpeechTime < 1000) {
                    return
                }
                viewModelScope.launch {
                    if (_state.value != AiState.LISTENING) {
                        switchState(AiState.LISTENING)
                        hasListeningState = true
                    }
                }
            } else { // ai agent is active speaker
                if (hasListeningState) {
                    viewModelScope.launch {
                        if (_state.value != AiState.SPEAKING) {
                            switchState(AiState.SPEAKING)
                        }
                    }
                }
            }
            lastLocalSpeechTime = currentTime
        }
    }

    private val roomHandler: IRTCRoomEventHandler = object : IRTCRoomEventHandler() {
        override fun onRoomStateChanged(
            roomId: String?,
            uid: String?,
            state: Int,
            extraInfo: String?
        ) {
            Log.d(
                TAG,
                String.format("onRoomStateChanged: %s, %s,%d,%s", roomId, uid, state, extraInfo)
            )
            if (state == 0) {
                viewModelScope.launch(Dispatchers.IO) {

                    if (roomId != aiChatRoomId) {
                        Log.d(
                            TAG,
                            "roomId has changed, do not start ai chat task. roomId : ".plus(roomId)
                        )
                        return@launch
                    }

                    try {
                        if (settings.integrationMode.value == IntegrationMode.REALTIME) {
                            val resMsg = startRealTimeVoiceChat(roomId!!, uid!!)
                            Log.d(
                                TAG,
                                String.format(
                                    "startRealTimeVoiceChat. Response message: %s",
                                    resMsg
                                )
                            )
                        } else {
                            val resMsg = startFlexibleVoiceChat(roomId!!, uid!!)
                            Log.d(
                                TAG,
                                String.format(
                                    "startFlexibleVoiceChat. Response message: %s",
                                    resMsg
                                )
                            )
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "start voice chat. error : ".plus(e.message))
                        CenteredToast.show(R.string.toast_ai_call_failed)
                        viewModelScope.launch {
                            hangup()
                        }
                    }
                }
            } else {
                CenteredToast.show(R.string.toast_ai_call_failed)
            }
        }

        override fun onUserJoined(userInfo: UserInfo?, elapsed: Int) {
            Log.d(TAG, String.format("onUserJoined: %s", userInfo?.uid))
            viewModelScope.launch(Dispatchers.Main) {
                _startTime.value = SystemClock.uptimeMillis()
                switchState(AiState.PREPARED)
            }
        }

        override fun onUserLeave(uid: String?, reason: Int) {
            Log.d(TAG, String.format("onUserLeave: %s, reason : %d", uid, reason))
        }

        override fun onUserPublishStreamAudio(roomId: String?, uid: String?, isPublish: Boolean) {
            Log.d(
                TAG,
                String.format("onUserPublishStreamAudio: %s, isPublish : %b", uid, isPublish)
            )
        }

        override fun onUserPublishStreamVideo(roomId: String?, uid: String?, isPublish: Boolean) {
            Log.d(
                TAG,
                String.format("onUserPublishStreamVideo: %s, isPublish : %b", uid, isPublish)
            )
        }

    }

    private val _state = MutableLiveData(AiState.NONE)
    private val _hadHungUp: AtomicBoolean = AtomicBoolean(false)

    private var rtcVideo: RTCVideo? = null
        set(value) {
            field?.stopAudioCapture()
            field = value
        }

    private var rtcRoom: RTCRoom? = null
        set(value) {
            field?.leaveRoom()
            field?.destroy()
            field = value
        }

    private var aiChatRoomId: String? = null
        get() {
            if (field == null) {
                field = UUID.randomUUID().toString()
            }
            return field
        }

    val state: LiveData<AiState>
        get() = _state

    private val _startTime = MutableLiveData<Long>()


    val startTime: LiveData<Long>
        get() = _startTime

    private var hasListeningState: Boolean = false
    private var lastLocalSpeechTime: Long = 0
    private var lastKeepAiAgentQuestionsTime: Long = 0

    private fun switchState(state: AiState) {
        if ((state == AiState.SPEAKING || state == AiState.LISTENING || state == AiState.PREPARED)
            && _state.value == AiState.MUTED
        ) {
            return
        }
        _state.value = state
    }

    fun config() {
        viewModelScope.launch {
            withContext(Dispatchers.IO) {
                val lang = Locale.getDefault().toLanguageTag().lowercase()
                try {
                    val config = chatApi.getAiConfig(lang)
                    if (config != null) {
                        settings.updateAiConfig(config)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Get ai config. error : ".plus(e.message))
                    CenteredToast.show(R.string.toast_ai_call_failed)
                }
            }
            switchState(AiState.CONFIGURED)
        }
    }

    fun prepare() {
        val userId: String = SolutionDataManager.userId!!
        _hadHungUp.set(false)
        val roomId: String = aiChatRoomId!!
        viewModelScope.launch {
            val token = withContext(Dispatchers.IO) {
                requestRTCRoomToken(roomId, userId)
            }
            if (_hadHungUp.get()) {
                return@launch
            }
            if (token.isEmpty()) {
                hangup()
                CenteredToast.show(R.string.toast_ai_call_failed)
                return@launch
            }
            joinRTCRoom(roomId, userId, token)
        }
    }

    fun listen() {
        viewModelScope.launch {
            delay(1000L)
            // _state.value = AiState.LISTENING
        }
    }

    fun think() {
        viewModelScope.launch {
            delay(1000L)
            // _state.value = AiState.THINKING
        }
    }

    fun speak() {
        viewModelScope.launch {
            delay(1000L)
            // _state.value = AiState.SPEAKING
        }
    }

    fun hangup() {
        _startTime.value = 0
        _hadHungUp.set(true)
        val userId: String = SolutionDataManager.userId!!
        val stopRoomID: String = aiChatRoomId!!
        viewModelScope.launch(Dispatchers.IO) {
            try {
                if (settings.integrationMode.value == IntegrationMode.REALTIME) {
                    stopRealTimeVoiceChat(stopRoomID, userId)
                } else {
                    stopFlexibleVoiceChat(stopRoomID, userId)
                }
            } catch (e: Exception) {
                Log.e(TAG, "stop voice chat error : ".plus(e.message))
            }
        }
        aiChatRoomId = null
        lastKeepAiAgentQuestionsTime = 0
        lastLocalSpeechTime = 0
        hasListeningState = false
        rtcRoom = null
        RTCVideo.destroyRTCVideo()
        rtcVideo = null
        switchState(AiState.NONE)
        fragment.findNavController().popBackStack()
    }

    fun mute(mute: Boolean) {
        if (mute) {
            switchState(AiState.MUTED)
            rtcRoom?.publishStreamAudio(false)
        } else {
            rtcRoom?.publishStreamAudio(true)
            switchState(AiState.NONE)
        }
    }

    private suspend fun requestRTCRoomToken(
        roomId: String = UUID.randomUUID().toString(),
        userId: String = SolutionDataManager.userId!!
    ): String {
        val params = mutableMapOf<String, Any>(
            "room_id" to roomId,
            "user_id" to userId,
            "pub" to true,
            "expire" to TRIAL_TIME_SECONDS, // seconds
            "login_token" to SolutionDataManager.token!!
        )

        if (APP_ID.isNotEmpty()) {
            params["app_id"] = APP_ID
        }

        if (APP_KEY.isNotEmpty()) {
            params["app_key"] = APP_KEY
        }

        try {
            val result = chatApi.getRTCRoomToken(params)
            return result!!.token
        } catch (e: Exception) {
            Log.e(TAG, "Get rtc room token. error : ".plus(e.message))
        }
        return ""
    }

    private suspend fun startRealTimeVoiceChat(
        roomId: String,
        userId: String
    ): String {
        val params = mutableMapOf<String, Any>(
            "rtc_app_id" to rtcAppInfo.appId,
            "room_id" to roomId,
            "user_id" to userId,
            "voice_type" to settings.voiceTypeRealtime.value!!.value.voiceType.name,
            "voice_provider" to settings.voiceTypeRealtime.value!!.value.provider.name,
            "prompt" to settings.prompt.value!!.value,
            "welcome_speech" to settings.welcomeSpeech.value!!.value
        )

        val result = chatApi.startRealTimeVoiceChat(params)

        return result.message()
    }

    private suspend fun stopRealTimeVoiceChat(
        roomId: String,
        userId: String
    ): String {
        val params = mutableMapOf<String, Any>(
            "rtc_app_id" to rtcAppInfo.appId,
            "room_id" to roomId,
            "user_id" to userId
        )

        val result = chatApi.stopRealTimeVoiceChat(params)
        Log.d(
            TAG,
            String.format("stopRealTimeVoiceChat. %s, %s,%s", roomId, userId, result.message())
        )
        return result.message()
    }

    private suspend fun startFlexibleVoiceChat(
        roomId: String,
        userId: String
    ): String {
        val params = mutableMapOf<String, Any>(
            "rtc_app_id" to rtcAppInfo.appId,
            "room_id" to roomId,
            "user_id" to userId,
            "voice_type" to settings.voiceTypeFlexible.value!!.value.voiceType.name,
            "voice_provider" to settings.voiceTypeFlexible.value!!.value.provider.name,
            "llm_provider" to settings.llmModel.value!!.value,
            "asr_provider" to settings.asrModel.value!!.value,
            "prompt" to settings.prompt.value!!.value,
            "welcome_speech" to settings.welcomeSpeech.value!!.value
        )

        val result = chatApi.startFlexibleVoiceChat(params)
        Log.d(
            TAG,
            String.format("startFlexibleVoiceChat. %s, %s,%s", roomId, userId, result.message())
        )
        return result.message()
    }

    private suspend fun stopFlexibleVoiceChat(
        roomId: String,
        userId: String
    ): String {
        val params = mutableMapOf<String, Any>(
            "rtc_app_id" to rtcAppInfo.appId,
            "room_id" to roomId,
            "user_id" to userId
        )

        val result = chatApi.stopFlexibleVoiceChat(params)
        Log.d(
            TAG,
            String.format("stopFlexibleVoiceChat. %s, %s,%s", roomId, userId, result.message())
        )
        return result.message()
    }

    private fun joinRTCRoom(roomId: String, userId: String, token: String) {
        rtcVideo = RTCVideo.createRTCVideo(context, rtcAppInfo.appId, videoHandler, null, null)
        rtcVideo!!.startAudioCapture()

        val audioPropertiesConfig = AudioPropertiesConfig(700)
        rtcVideo!!.enableAudioPropertiesReport(audioPropertiesConfig)

        val userInfo = UserInfo(userId, null)
        val roomConfig = RTCRoomConfig(
            ChannelProfile.CHANNEL_PROFILE_CHAT,
            false, false,
            true, false
        )
        rtcRoom = rtcVideo!!.createRTCRoom(roomId).apply {
            setRTCRoomEventHandler(roomHandler)
            joinRoom(token, userInfo, roomConfig)
            publishStreamAudio(true)
        }
    }
}

val KEY_CONTEXT = object : CreationExtras.Key<Application> {}
val KEY_FRAGMENT = object : CreationExtras.Key<Fragment> {}
val KEY_RTC_APP_INFO = object : CreationExtras.Key<RTCAppInfo> {}
val KEY_SETTINGS_VIEW_MODEL = object : CreationExtras.Key<SettingsViewModel> {}

val AiChatViewModelInitializer = ViewModelInitializer(AiChatViewModel::class) {
    AiChatViewModel(
        this[KEY_CONTEXT]!!,
        this[KEY_FRAGMENT]!!,
        this[KEY_RTC_APP_INFO]!!,
        this[KEY_SETTINGS_VIEW_MODEL]!!
    )
}