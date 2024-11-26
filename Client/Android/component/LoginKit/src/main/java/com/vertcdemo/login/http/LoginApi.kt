// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.http

import com.vertcdemo.core.entity.LoginInfo
import com.vertcdemo.core.net.EventBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface LoginApi {
    @POST("login")
    fun login(@Body request: EventBody): Call<LoginInfo>
}
