// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net

import com.google.gson.JsonElement
import com.google.gson.annotations.SerializedName
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.common.GsonUtils
import com.vertcdemo.core.event.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import okhttp3.Interceptor
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.Response
import okhttp3.ResponseBody.Companion.toResponseBody
import java.io.IOException

class EventReturn(
    @SerializedName("code")
    var code: Int,
    @SerializedName("message")
    var message: String,
    @SerializedName("response")
    var response: JsonElement?
) {
    fun string(): String? = response?.toString()
}

object EventReturnInterceptor : Interceptor {
    @Throws(IOException::class)
    override fun intercept(chain: Interceptor.Chain): Response {
        val response = chain.proceed(chain.request())
        response.body.use { responseBody ->
            if (!response.isSuccessful) {
                responseBody?.close()
                throw HttpException.unknown("http code = " + response.code)
            } else {
                if (responseBody == null) {
                    throw HttpException.unknown("ResponseBody is null")
                }
                val eventReturn = GsonUtils.gson()
                    .fromJson(responseBody.string(), EventReturn::class.java)

                if (eventReturn.code == 200) {
                    val newBody = eventReturn.string()?.toResponseBody(APPLICATION_JSON)
                    return response.newBuilder()
                        .body(newBody)
                        .build()
                } else {
                    if (eventReturn.code == HttpException.ERROR_CODE_TOKEN_EXPIRED
                        || eventReturn.code == HttpException.ERROR_CODE_TOKEN_EMPTY
                    ) {
                        SolutionDataManager.token = ""
                        SolutionEventBus.post(AppTokenExpiredEvent())
                    }
                    throw HttpException(eventReturn.code, eventReturn.message)
                }
            }
        }
    }

    private val APPLICATION_JSON: MediaType = "application/json; charset=utf-8".toMediaType()
}
