// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertc.api.example.entry;

import static com.vertcdemo.base.BuildConfig.SERVER_URL;
import static com.vertcdemo.core.BuildConfig.APP_ID;
import static com.vertcdemo.core.BuildConfig.APP_KEY;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertc.api.example.base.RTCTokenProvider;
import com.vertc.api.example.entry.bean.GetRTCJoinRoomTokenResult;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.http.HttpRequestHelper;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Future;

public class RemoteRTCTokenProvider implements RTCTokenProvider {
    private static final String TAG = "RemoteRTCTokenProvider";
    private static final String TOKEN_URL = SERVER_URL + "/getRTCJoinRoomToken";

    private final String appId;

    public RemoteRTCTokenProvider(@NonNull String appId) {
        this.appId = appId;
    }

    @Nullable
    @Override
    public String getAppId() {
        return appId;
    }

    @NonNull
    @Override
    public Future<String> getToken(@NonNull String roomId, @NonNull String userId) {
        return AppExecutors.networkIO().submit(() -> getRTCJoinRoomToken(roomId, userId));
    }

    private String getRTCJoinRoomToken(String roomId, String userId) throws Exception {
        String[] token = new String[1];
        JSONObject params = new JSONObject();
        try {
            params.put("room_id", roomId);
            params.put("user_id", userId);
            params.put("pub", true);
            params.put("expire", 1200);// seconds
            params.put("login_token", SolutionDataManager.ins().getToken());

            if (!TextUtils.isEmpty(APP_KEY)) {
                params.put("app_key", APP_KEY);
            }
            if (!TextUtils.isEmpty(APP_ID)) {
                params.put("app_id", APP_ID);
            }
        } catch (JSONException e) {
            throw new Exception(e);
        }

        CountDownLatch latch = new CountDownLatch(1);
        HttpRequestHelper.sendPostAsync(TOKEN_URL,
                params,
                GetRTCJoinRoomTokenResult.class, new IRequestCallback<ServerResponse<GetRTCJoinRoomTokenResult>>() {
                    @Override
                    public void onSuccess(ServerResponse<GetRTCJoinRoomTokenResult> data) {
                        GetRTCJoinRoomTokenResult result = data.getData();
                        token[0] = result == null ? "" : result.token;
                        latch.countDown();
                    }

                    @Override
                    public void onError(int errorCode, @Nullable String message) {
                        Log.d(TAG, "getRTCJoinRoomToken:" + ErrorTool.getErrorMessageByErrorCode(errorCode, message));
                        latch.countDown();
                    }
                });
        try {
            latch.await();
        } catch (InterruptedException e) {
            throw new Exception(e);
        }
        return token[0];
    }
}
