// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.net

import com.google.gson.annotations.SerializedName
import com.vertcdemo.base.R
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.utils.AppUtil.applicationContext

class EventBody(
    @SerializedName("event_name")
    val eventName: String,
    @SerializedName("content")
    val content: String
) {
    @SerializedName("device_id")
    val deviceId: String = SolutionDataManager.ins().deviceId

    @SerializedName("language")
    val language: String = applicationContext.getString(R.string.language_code)
}