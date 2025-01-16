// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.model

import com.byteplus.vod.scenekit.data.model.VideoItem
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.network.model.UserStatus

class VodFeedItem(
    @UserStatus val userStatus: Int,
    val videoItem: VideoItem,
    val roomInfo: LiveFeedItem? = null,
) : FeedItem {
    val isLive: Boolean
        get() = userStatus == UserStatus.LIVE && roomInfo != null
}