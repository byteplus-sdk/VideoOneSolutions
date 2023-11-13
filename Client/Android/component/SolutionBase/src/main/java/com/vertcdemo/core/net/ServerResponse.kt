// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.net

import com.google.gson.annotations.SerializedName

class ServerResponse<T>(
    @JvmField
    @SerializedName("code")
    var code: Int,
    @JvmField
    @SerializedName("message")
    var message: String,
    @JvmField
    @SerializedName("response")
    var response: T
) {
    val data: T? get() = response
}
