// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.rtc.toolkit.BuildConfig;

import java.util.Objects;

public class AppInfoManager {
    private static final String TAG = "AppInfoManager";

    private static final String EVENT_GET_APP_INFO = "getAppInfo";

    public static void requestInfo(String sceneName, @NonNull Callback<RTCAppInfo> callback) {
        JsonObject content = new JsonObject();
        content.addProperty("scenes_name", sceneName);
        requestInfo(content, callback);
    }

    public static void requestInfo(@NonNull JsonObject content, @NonNull Callback<RTCAppInfo> callback) {
        if (!TextUtils.isEmpty(BuildConfig.APP_ID)) { // AppId Set, use OSS mode
            Log.d(TAG, "joinRTS: APP_ID found. Switch client mode.");
            if (TextUtils.isEmpty(BuildConfig.APP_KEY)) {
                callback.onFailure(HttpException.unknown("AppKey is empty"));
                return;
            }

            if (TextUtils.isEmpty(BuildConfig.ACCESS_KEY_ID)) {
                callback.onFailure(HttpException.unknown("AccessKeyID is empty"));
                return;
            }

            if (TextUtils.isEmpty(BuildConfig.SECRET_ACCESS_KEY)) {
                callback.onFailure(HttpException.unknown("SecretAccessKey is empty"));
                return;
            }

            content.addProperty("app_id", BuildConfig.APP_ID);
            content.addProperty("app_key", BuildConfig.APP_KEY);
            content.addProperty("access_key", BuildConfig.ACCESS_KEY_ID);
            content.addProperty("secret_access_key", BuildConfig.SECRET_ACCESS_KEY);
        }

        String token = Objects.requireNonNull(SolutionDataManager.ins().getToken());

        HttpClient.request(EVENT_GET_APP_INFO, token, content, RTCAppInfo.class, callback);
    }
}
