// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.http.request

import com.vertcdemo.core.common.GsonUtils
import com.vertcdemo.core.net.EventBody

object LoginRequest {
    fun create(userName: String) = EventBody(
        eventName = "passwordFreeLogin",
        content = GsonUtils.gson().toJson(mapOf("user_name" to userName))
    )
}