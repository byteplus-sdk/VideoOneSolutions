// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login.net;

import android.util.Log;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.http.HttpRequestHelper;
import com.vertcdemo.core.entity.LoginInfo;

import org.json.JSONObject;

public class LoginApi {
    private static final String TAG = "LoginApi";

    public static void passwordFreeLogin(String userName, IRequestCallback<ServerResponse<LoginInfo>> callBack) {
        try {
            JSONObject content = new JSONObject();
            content.put("user_name", userName);

            JSONObject params = new JSONObject();
            params.put("event_name", "passwordFreeLogin");
            params.put("content", content.toString());
            params.put("device_id", SolutionDataManager.ins().getDeviceId());

            HttpRequestHelper.sendPost(params, LoginInfo.class, callBack);
        } catch (Exception e) {
            Log.d(TAG, "verifyLoginSms failed:", e);
            callBack.onError(-1, "Content Error");
        }
    }

    public static void changeUserName(String userName, String loginToken, IRequestCallback<ServerResponse<Void>> callBack) {
        try {
            JSONObject content = new JSONObject();
            content.put("user_name", userName);
            content.put("login_token", loginToken);

            JSONObject params = new JSONObject();
            params.put("event_name", "changeUserName");
            params.put("content", content.toString());
            params.put("device_id", SolutionDataManager.ins().getDeviceId());

            HttpRequestHelper.sendPost(params, Void.class, callBack);
        } catch (Exception e) {
            Log.d(TAG, "changeUserName failed:", e);
            callBack.onError(-1, "Content Error");
        }
    }
}
