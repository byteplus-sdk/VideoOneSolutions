// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.room

import android.content.Context
import android.util.Log
import com.byteplus.vodlive.live.event.AudienceChanged
import com.byteplus.vodlive.live.event.JoinRTSRoomEvent
import com.byteplus.vodlive.live.event.MessageBody
import com.byteplus.vodlive.live.event.MessageReceivedEvent
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.google.gson.JsonElement
import com.google.gson.annotations.SerializedName
import com.ss.bytertc.engine.RTCRoom
import com.ss.bytertc.engine.RTCRoomConfig
import com.ss.bytertc.engine.RTCEngine
import com.ss.bytertc.engine.UserInfo
import com.ss.bytertc.engine.data.EngineConfig
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler
import com.ss.bytertc.engine.handler.IRTCEngineEventHandler
import com.ss.bytertc.engine.type.ChannelProfile
import com.ss.bytertc.engine.type.RTCRoomStats
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.common.GsonUtils

class RTCRoomManager(private val context: Context) {

    companion object {
        private const val TAG = "RTCRoomManager"
    }

    private val videoHandler: IRTCEngineEventHandler = object : IRTCEngineEventHandler() {}

    private var rtcVideo: RTCEngine? = null

    private val roomConfig: RTCRoomConfig =
        RTCRoomConfig(
            ChannelProfile.CHANNEL_PROFILE_CHAT_ROOM,
            false, false, false, false
        )

    private val userInfo = UserInfo(SolutionDataManager.userId!!, "")

    private var rtsRoom: RTCRoom? = null
        set(value) {
            field?.leaveRoom()
            field?.destroy()
            field = value
        }

    fun switchRoom(item: LiveFeedItem) {
        val rtcVideo =
            rtcVideo ?: run {
                val engineConfig = EngineConfig().apply {
                    this.context = context
                    this.appID = item.rtcAppId
                    this.isGameScene = false
                }
                RTCEngine.createRTCEngine(engineConfig, videoHandler).also {
                    it.setBusinessId(RTCManager.bid)
                    this.rtcVideo = it
                }
            }

        rtsRoom = rtcVideo.createRTCRoom(item.roomId).apply {
            setRTCRoomEventHandler(RTCRoomEventHandler(item.roomId))
            joinRoom(item.rtsToken, userInfo, false, roomConfig)
        }
    }

    fun onCleared() {
        rtsRoom = null
        RTCEngine.destroyRTCEngine()
        rtcVideo = null
    }

    class RTCRoomEventHandler(private val roomId: String) : IRTCRoomEventHandler() {
        override fun onRoomStateChanged(
            roomId: String,
            uid: String,
            state: Int,
            extraInfo: String?
        ) {
            Log.d(
                TAG,
                "onRoomStateChanged: roomId=$roomId, userId=$uid, state=$state, extraInfo=$extraInfo"
            )
            RoomEventBus.post(JoinRTSRoomEvent(roomId))
        }

        override fun onLeaveRoom(stats: RTCRoomStats) {
            Log.d(TAG, "onLeaveRoom: roomId=$roomId")
        }

        override fun onRoomMessageReceived(uid: String, message: String) {
            Log.d(TAG, "onRoomMessageReceived: roomId=$roomId, userId=$uid, $message")
            if ("server" == uid) {
                val rawEvent = GsonUtils.gson().fromJson(message, RTSEvent::class.java)
                when (rawEvent.event) {
                    "feedLiveOnMessageSend" -> {
                        rawEvent.data?.let { data ->
                            handleUserMessage(data)
                        }
                    }

                    "feedLiveOnUserJoin", "feedLiveOnUserLeave" -> {
                        rawEvent.data?.let { data ->
                            handleAudienceCountChanged(data)
                        }
                    }
                }
            }
        }

        private fun handleUserMessage(element: JsonElement) {
            val body = element.asJsonObject
            val userId = body.get("user_id").asString ?: return
            val userName = body.get("user_name").asString ?: return
            val message = body.get("message").asString ?: return
            val messageBody = GsonUtils.gson().fromJson(message, MessageBody::class.java)
            RoomEventBus.post(
                MessageReceivedEvent(
                    roomId = roomId,
                    userId = userId,
                    userName = userName,
                    body = messageBody
                )
            )
        }

        private fun handleAudienceCountChanged(element: JsonElement) {
            val event = GsonUtils.gson().fromJson(element, AudienceChanged::class.java)
            event.roomId = roomId
            RoomEventBus.post(event)
        }
    }
}

class RTSEvent(
    @SerializedName("event")
    val event: String,
    @SerializedName("data")
    val data: JsonElement?,
)
