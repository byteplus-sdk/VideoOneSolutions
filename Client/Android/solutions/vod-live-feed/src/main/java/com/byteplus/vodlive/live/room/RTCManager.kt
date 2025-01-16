// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.room

import com.vertcdemo.core.http.bean.RTCAppInfo

object RTCManager {
    var rtcAppInfo: RTCAppInfo? = null

    val bid: String
        get() = rtcAppInfo?.bid ?: "veRTC_live_feed"
}