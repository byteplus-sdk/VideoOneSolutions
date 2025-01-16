// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import com.byteplus.vodlive.live.event.JoinBusinessEvent
import com.byteplus.vodlive.live.event.MSG_GIFT_DIAMOND
import com.byteplus.vodlive.live.event.MSG_GIFT_FIREWORKS
import com.byteplus.vodlive.live.event.MSG_GIFT_LIKE
import com.byteplus.vodlive.live.event.MSG_GIFT_SUGAR
import com.byteplus.vodlive.live.event.MSG_LIKE
import com.byteplus.vodlive.live.event.MessageBody
import com.byteplus.vodlive.live.room.RTCRoomManager
import com.byteplus.vodlive.live.room.RoomEventBus
import com.byteplus.vodlive.network.VOD_PAGE_SIZE
import com.byteplus.vodlive.network.model.GetLiveOnlyRequest
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.network.model.SendMessageRequest
import com.byteplus.vodlive.network.model.SwitchLiveRoomRequest
import com.byteplus.vodlive.network.vodLiveApi
import com.byteplus.vodlive.viewmodel.PageViewModel
import com.vertcdemo.core.chat.annotation.GiftType
import com.vertcdemo.core.common.GsonUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

object LiveItemKey : CreationExtras.Key<LiveFeedItem?>

object RoomManagerKey : CreationExtras.Key<RTCRoomManager>

class LiveFeedViewModel(
    private val roomManager: RTCRoomManager,
    private val initial: LiveFeedItem?
) : PageViewModel() {

    companion object {
        private const val TAG = "LiveFeedViewModel"
    }

    private val _liveItemFlow: MutableStateFlow<List<LiveFeedItem>> =
        MutableStateFlow(listOfNotNull(initial))
    val liveItemFlow: StateFlow<List<LiveFeedItem>> = _liveItemFlow

    var currentItem: LiveFeedItem? = null
        private set

    fun loadNext() {
        viewModelScope.launch {
            loadImpl(page = pageIndex + 1)
        }
    }

    private suspend fun loadImpl(page: Int) {
        if (loading) {
            return
        }
        loading = true
        val items = withContext(Dispatchers.IO) {
            runCatching {
                vodLiveApi.getFeedOnlyLive(
                    GetLiveOnlyRequest.page(
                        page = page,
                        firstRoomId = initial?.roomId ?: "",
                        pageSize = VOD_PAGE_SIZE
                    )
                )
            }.getOrNull()
        }?.body() ?: emptyList()

        hasMore = (items.size >= VOD_PAGE_SIZE)
        loading = false
        pageIndex = page

        _liveItemFlow.value += items
    }

    fun switchRoom(item: LiveFeedItem) {
        roomManager.switchRoom(item)

        viewModelScope.launch(Dispatchers.IO) {
            switchRoomImpl(item)
        }
    }

    private suspend fun switchRoomImpl(item: LiveFeedItem?) {
        val result = kotlin.runCatching {
            vodLiveApi.switchLiveRoom(
                SwitchLiveRoomRequest(
                    oldRoomId = currentItem?.roomId,
                    newRoomId = item?.roomId,
                    rtcAppId = item?.rtcAppId
                )
            )
        }.getOrNull()
        Log.d(
            TAG,
            "switchRoom: ${currentItem?.roomId} -> ${item?.roomId}, audienceCount: ${result?.audienceCount}"
        )

        if (item != null) {
            RoomEventBus.post(JoinBusinessEvent(item.roomId, result?.audienceCount ?: 1))
        }

        currentItem = item
    }

    override fun onCleared() {
        super.onCleared()
        roomManager.onCleared()
        /**
         * Clear action should using a new coroutine scope,
         * viewModelScope not available here
         */
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
        scope.launch {
            switchRoomImpl(null)
        }
    }

    fun sendGift(item: LiveFeedItem, giftType: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            val message = when (giftType) {
                GiftType.LIKE -> GsonUtils.gson().toJson(MSG_GIFT_LIKE)
                GiftType.SUGAR -> GsonUtils.gson().toJson(MSG_GIFT_SUGAR)
                GiftType.DIAMOND -> GsonUtils.gson().toJson(MSG_GIFT_DIAMOND)
                GiftType.FIREWORKS -> GsonUtils.gson().toJson(MSG_GIFT_FIREWORKS)
                else -> return@launch
            }

            val request = SendMessageRequest(
                roomId = item.roomId,
                message = message,
                appId = item.rtcAppId
            )

            vodLiveApi.sendMessage(request)
        }
    }

    fun sendLike(item: LiveFeedItem) {
        viewModelScope.launch(Dispatchers.IO) {
            val message = GsonUtils.gson().toJson(MSG_LIKE)
            val request = SendMessageRequest(
                roomId = item.roomId,
                message = message,
                appId = item.rtcAppId
            )

            vodLiveApi.sendMessage(request)
        }
    }

    fun sendMessage(item: LiveFeedItem, content: String) {
        viewModelScope.launch(Dispatchers.IO) {
            val message = GsonUtils.gson().toJson(MessageBody(content = content))
            val request = SendMessageRequest(
                roomId = item.roomId,
                message = message,
                appId = item.rtcAppId
            )

            vodLiveApi.sendMessage(request)
        }
    }
}

class LiveFeedViewModelFactory : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T {
        return when (modelClass) {
            LiveFeedViewModel::class.java -> {
                val manager = extras[RoomManagerKey]!!
                val initial = extras[LiveItemKey]
                LiveFeedViewModel(manager, initial) as T
            }

            else -> super.create(modelClass, extras)
        }
    }
}