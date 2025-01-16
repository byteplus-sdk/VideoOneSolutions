// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.network.model

import android.os.Parcelable
import com.byteplus.vodlive.model.FeedItem
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
class LiveFeedItem(
    @SerializedName("rtc_app_id")
    val rtcAppId: String,
    @SerializedName("room_id")
    val roomId: String,
    @SerializedName("room_name")
    val roomName: String,
    @SerializedName("room_desc")
    val roomDesc: String,
    @SerializedName("cover_url")
    val coverUrl: String,
    @SerializedName("host_name")
    val hostName: String,
    @SerializedName("host_user_id")
    val hostUserId: String,
    @SerializedName("rts_token")
    val rtsToken: String,
    @SerializedName("stream_pull_url_list")
    val pullUrlList: Map<String, String>?,
    @Transient
    var disableCover: Boolean = false,
) : FeedItem, Parcelable {
    val liveUrl: String?
        get() {

            val urls = pullUrlList ?: return null

            val resolutions = listOf("720", "1080", "540", "360")
            return resolutions.firstNotNullOfOrNull { urls[it] }
                ?: urls.firstNotNullOfOrNull { it.value }
        }
}