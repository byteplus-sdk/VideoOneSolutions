// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.network.model

import com.byteplus.vod.scenekit.data.model.VideoItem
import com.google.gson.annotations.SerializedName
import java.util.Date

class PlayAuthTokenVideoDetail(
    @SerializedName("vid")
    val vid: String,
    @SerializedName("caption")
    val caption: String,
    @SerializedName("duration")
    val duration: Double,
    @SerializedName("cover_url")
    val coverUrl: String,
    @SerializedName("play_auth_token")
    val playAuthToken: String,
    @SerializedName("subtitle_auth_token")
    val subtitleAuthToken: String,
    @SerializedName("play_times")
    val playTimes: Int,
    @SerializedName("subtitle")
    val subtitle: String,
    @SerializedName("create_time")
    val createTime: Date,
    @SerializedName("name")
    val userName: String,
    @SerializedName("uid")
    val userId: String,
    @SerializedName("like")
    val likeCount: Int,
    @SerializedName("comment")
    val commentCount: Int,
    @SerializedName("height")
    val height: Int,
    @SerializedName("width")
    val width: Int
) {
    fun toItem(): VideoItem {
        val item = VideoItem.createVidItem(
            vid,
            playAuthToken,
            subtitleAuthToken,
            (duration * 1000).toLong(),
            coverUrl,
            caption
        )

        item.subtitle = subtitle
        item.playCount = playTimes
        item.createTime = createTime
        item.setSize(width, height)
        item.setUser(userId, userName)
        item.likeCount = likeCount
        item.commentCount = commentCount

        return item
    }
}
