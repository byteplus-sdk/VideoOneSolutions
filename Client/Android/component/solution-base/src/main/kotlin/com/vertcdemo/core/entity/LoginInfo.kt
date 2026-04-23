// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.entity

import com.google.gson.annotations.SerializedName

class LoginInfo {
    @JvmField
    @SerializedName("user_id")
    var userId: String? = null

    @JvmField
    @SerializedName("user_name")
    var userName: String? = null

    @JvmField
    @SerializedName("login_token")
    var loginToken: String? = null

    override fun toString() =
        "LoginInfo{userId='${userId}', userName='$userName', loginToken='$loginToken'}"
}
