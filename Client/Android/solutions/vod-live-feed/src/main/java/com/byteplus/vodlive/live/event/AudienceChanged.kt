// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.event

import com.google.gson.annotations.SerializedName

class AudienceChanged(
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("user_name")
    val userName: String,
    @SerializedName("audience_count")
    val audienceCount: Int
) {
    @Transient
    var roomId: String = ""
}