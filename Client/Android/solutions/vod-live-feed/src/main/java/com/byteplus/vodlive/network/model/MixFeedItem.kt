// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.network.model

import com.byteplus.vodlive.model.FeedItem
import com.byteplus.vodlive.model.VodFeedItem
import com.google.gson.annotations.SerializedName

class MixFeedItem(
    @FeedType
    @SerializedName("video_type")
    val type: Int,

    @UserStatus
    @SerializedName("user_status")
    val userStatus: Int,

    @SerializedName("video_info")
    val videoInfo: PlayAuthTokenVideoDetail? = null,

    @SerializedName("room_info")
    val roomInfo: LiveFeedItem? = null
) {
    fun asFeed(): FeedItem? {
        when {
            type == FeedType.VOD && videoInfo != null -> {
                val videoItem = videoInfo.toItem()
                return VodFeedItem(userStatus, videoItem, roomInfo)
            }

            type == FeedType.LIVE && roomInfo != null -> {
                return roomInfo
            }

            else -> {
                return null
            }
        }
    }
}