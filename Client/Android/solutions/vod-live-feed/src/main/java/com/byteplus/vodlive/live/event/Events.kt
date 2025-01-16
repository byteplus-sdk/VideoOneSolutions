// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.event

import com.byteplus.vodlive.annotation.MessageType
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.vertcdemo.core.chat.bean.IGiftEvent

sealed class JoinRoomEvent(val roomId: String)

class JoinRTSRoomEvent(roomId: String) : JoinRoomEvent(roomId)

class JoinBusinessEvent(roomId: String, val audienceCount: Int) : JoinRoomEvent(roomId)

class MessageReceivedEvent(
    val roomId: String,
    private val userId: String,
    private val userName: String,
    private val body: MessageBody,
) : IGiftEvent {
    @MessageType
    val type: Int
        get() = body.type

    val content: String
        get() = body.content ?: ""

    override fun getGiftType(): Int = body.giftType

    override fun getUserId(): String = userId

    override fun getUserName(): String = userName

    override fun getCount(): Int = body.count
}

sealed interface ActionEvent

data object CloseAction : ActionEvent
data class GiftAction(val item: LiveFeedItem) : ActionEvent
data class LikeAction(val item: LiveFeedItem) : ActionEvent
data class CommentAction(val item: LiveFeedItem) : ActionEvent