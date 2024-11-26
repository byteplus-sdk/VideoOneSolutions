package com.byteplus.vodlive.network.model

import com.byteplus.vodlive.network.VOD_PAGE_SIZE
import com.google.gson.annotations.SerializedName
import com.vertcdemo.core.SolutionDataManager

class GetFeedWithLiveRequest(
    @SerializedName("offset")
    val offset: Int,
    @SerializedName("page_size")
    val pageSize: Int,
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("app_id")
    var rtcAppId: String? = null,
) {
    companion object {
        fun page(page: Int, pageSize: Int = VOD_PAGE_SIZE) =
            GetFeedWithLiveRequest(
                offset = page * pageSize,
                pageSize = pageSize,
                userId = SolutionDataManager.userId!!
            )
    }
}

class GetLiveOnlyRequest(
    @SerializedName("offset")
    val offset: Int,
    @SerializedName("page_size")
    val pageSize: Int,
    @SerializedName("room_id")
    val firstRoomId: String = "",
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("app_id")
    var rtcAppId: String? = null,
) {
    companion object {
        fun page(page: Int = 0, firstRoomId: String = "", pageSize: Int = VOD_PAGE_SIZE) =
            GetLiveOnlyRequest(
                offset = page * pageSize,
                pageSize = pageSize,
                userId = SolutionDataManager.userId!!,
                firstRoomId = firstRoomId
            )
    }
}

class SwitchLiveRoomRequest(
    @SerializedName("old_room_id")
    val oldRoomId: String?,
    @SerializedName("new_room_id")
    val newRoomId: String?,
    @SerializedName("user_id")
    val userId: String = SolutionDataManager.userId!!,
    @SerializedName("app_id")
    var rtcAppId: String? = null,
)

class SendMessageRequest(
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("message")
    val message: String,
    @SerializedName("user_id")
    val userId: String = SolutionDataManager.userId!!,
    @SerializedName("app_id")
    val appId: String? = null
)