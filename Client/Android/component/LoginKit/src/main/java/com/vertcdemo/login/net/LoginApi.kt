// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.net

import android.util.Log
import com.vertcdemo.core.SolutionDataManager.ins
import com.vertcdemo.core.entity.LoginInfo
import com.vertcdemo.core.net.IRequestCallback
import com.vertcdemo.core.net.ServerResponse
import com.vertcdemo.core.net.http.HttpRequestHelper.sendPost
import org.json.JSONObject

object LoginApi {
    private const val TAG = "LoginApi"
    fun passwordFreeLogin(
        userName: String?,
        callBack: IRequestCallback<ServerResponse<LoginInfo>>
    ) = try {
        val content = JSONObject().apply {
            put("user_name", userName)
        }

        val params = JSONObject().apply {
            put("event_name", "passwordFreeLogin")
            put("content", content.toString())
            put("device_id", ins().deviceId)
        }

        sendPost(params, LoginInfo::class.java, callBack)
    } catch (e: Exception) {
        Log.d(TAG, "verifyLoginSms failed:", e)
        callBack.onError(-1, "Content Error")
    }
}
