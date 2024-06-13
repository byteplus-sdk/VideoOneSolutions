// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.joinrtsparams.common;

import android.text.TextUtils;
import android.util.Log;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.vertcdemo.core.BuildConfig;
import com.vertcdemo.core.joinrtsparams.bean.JoinRTSRequest;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.http.HttpRequestHelper;
import com.vertcdemo.core.net.rts.RTSInfo;

import org.json.JSONObject;

public class JoinRTSManager {

    private static final String TAG = "JoinRTSManager";

    public static void requestRTSInfo(JoinRTSRequest request,
                                      IRequestCallback<ServerResponse<RTSInfo>> callBack) {
        String content;
        if (!TextUtils.isEmpty(BuildConfig.APP_ID)) { // AppId Set, use OSS mode
            Log.d(TAG, "joinRTS: APP_ID found. Switch client mode.");
            if (TextUtils.isEmpty(BuildConfig.APP_KEY)) {
                callBack.onError(-1, "AppKey is empty");
                return;
            }

            if (TextUtils.isEmpty(BuildConfig.ACCESS_KEY_ID)) {
                callBack.onError(-1, "AccessKeyID is empty");
                return;
            }

            if (TextUtils.isEmpty(BuildConfig.SECRET_ACCESS_KEY)) {
                callBack.onError(-1, "SecretAccessKey is empty");
                return;
            }

            JsonElement element = GsonUtils.gson().toJsonTree(request);
            JsonObject jsonObject = element.getAsJsonObject();
            jsonObject.addProperty("app_id", BuildConfig.APP_ID);
            jsonObject.addProperty("app_key", BuildConfig.APP_KEY);
            jsonObject.addProperty("access_key", BuildConfig.ACCESS_KEY_ID);
            jsonObject.addProperty("secret_access_key", BuildConfig.SECRET_ACCESS_KEY);

            content = jsonObject.toString();
        } else {
            Log.d(TAG, "joinRTS: no APP_ID. Switch server mode.");
            content = GsonUtils.gson().toJson(request);
        }

        try {
            JSONObject params = new JSONObject();
            params.put("event_name", "joinRTS");
            params.put("content", content);
            params.put("device_id", SolutionDataManager.ins().getDeviceId());

            Log.d(TAG, "joinRTS params: " + params);
            HttpRequestHelper.sendPostAsync(params, RTSInfo.class, callBack);
        } catch (Exception e) {
            Log.d(TAG, "joinRTS failed", e);
            callBack.onError(-1, e.getMessage());
        }
    }
}
