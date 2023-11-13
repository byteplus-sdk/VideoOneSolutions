// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.net.http

import android.content.Context
import android.util.Log
import androidx.annotation.AnyThread
import androidx.annotation.WorkerThread
import com.google.gson.reflect.TypeToken
import com.vertcdemo.base.BuildConfig
import com.vertcdemo.base.R
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.common.AppExecutors.mainThread
import com.vertcdemo.core.common.AppExecutors.networkIO
import com.vertcdemo.core.common.GsonUtils.gson
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.core.net.IRequestCallback
import com.vertcdemo.core.net.ServerResponse
import com.vertcdemo.core.utils.AppUtil.applicationContext
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit

object HttpRequestHelper {
    private const val TAG = "HttpRequestHelper"
    private const val ERROR_CODE_TOKEN_EXPIRED = 450
    private const val ERROR_CODE_TOKEN_EMPTY = 451
    private const val ERROR_CODE_UNKNOWN = -1

    private const val LOGIN_URL = BuildConfig.SERVER_URL + "/login"

    private val okHttpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .build()
    }

    @JvmStatic
    @AnyThread
    fun <T> sendPost(
        params: JSONObject,
        resultClass: Class<T>?,
        callBack: IRequestCallback<ServerResponse<T>?>
    ) {
        networkIO.execute { sendPost(LOGIN_URL, params, resultClass, callBack) }
    }

    @WorkerThread
    fun <T> sendPost(
        url: String,
        params: JSONObject,
        resultClass: Class<T>?,
        callBack: IRequestCallback<ServerResponse<T>?>
    ) {
        val context: Context = applicationContext
        val language = context.getString(R.string.language_code)
        params.put("language", language)

        val body = RequestBody.create(MediaType.get("application/json; charset=utf-8"), "$params")
        val request = Request.Builder()
            .url(url)
            .post(body)
            .build()
        val call = okHttpClient.newCall(request)
        try {
            call.execute().use { response ->
                Log.d(TAG, "Request: $params")
                if (!response.isSuccessful) {
                    throw IOException("http code = " + response.code())
                }
                val responseBody = response.body() ?: throw IOException("ResponseBody is null")
                val type = TypeToken.getParameterized(
                    ServerResponse::class.java, resultClass
                ).type
                val serverResponse = gson().fromJson<ServerResponse<T>>(responseBody.string(), type)
                val code = serverResponse.code
                if (code != 200) {
                    if (code == ERROR_CODE_TOKEN_EXPIRED || code == ERROR_CODE_TOKEN_EMPTY) {
                        SolutionDataManager.token = ""
                        SolutionEventBus.post(AppTokenExpiredEvent())
                    }
                    mainThread.execute { callBack.onError(code, serverResponse.message) }
                    return
                }
                mainThread.execute { callBack.onSuccess(serverResponse) }
            }
        } catch (e: IOException) {
            Log.d(TAG, "post fail url:$url", e)
            mainThread.execute { callBack.onError(ERROR_CODE_UNKNOWN, e.message) }
        }
    }
}
