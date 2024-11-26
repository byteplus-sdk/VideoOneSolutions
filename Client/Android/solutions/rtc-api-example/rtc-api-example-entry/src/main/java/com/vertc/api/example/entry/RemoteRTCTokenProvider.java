// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertc.api.example.entry;

import static com.vertcdemo.rtc.toolkit.BuildConfig.APP_ID;
import static com.vertcdemo.rtc.toolkit.BuildConfig.APP_KEY;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertc.api.example.base.RTCTokenProvider;
import com.vertc.api.example.entry.bean.GetRTCRoomTokenResult;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.net.SolutionRetrofit;

import java.io.IOException;
import java.util.HashMap;
import java.util.concurrent.Future;

import retrofit2.Response;

public class RemoteRTCTokenProvider implements RTCTokenProvider {
    private static final String TAG = "RemoteRTCTokenProvider";

    private final String appId;
    @Nullable
    private final String businessId;

    public RemoteRTCTokenProvider(@NonNull String appId, @Nullable String businessId) {
        this.appId = appId;
        this.businessId = businessId;
    }

    @Nullable
    @Override
    public String getAppId() {
        return appId;
    }

    @NonNull
    public String getBusinessId(String bid) {
        return "remote-" + businessId + "-" + bid;
    }

    @NonNull
    @Override
    public Future<String> getToken(@NonNull String roomId, @NonNull String userId) {
        return AppExecutors.networkIO().submit(() -> getRTCJoinRoomToken(roomId, userId));
    }

    private String getRTCJoinRoomToken(String roomId, String userId) throws IOException {
        HashMap<String, Object> params = new HashMap<>();
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

        Response<GetRTCRoomTokenResult> response = SolutionRetrofit.getApi(RTCTokenApi.class)
                .getToken(params)
                .execute();
        GetRTCRoomTokenResult result = response.body();
        return (result == null ? null : result.token);
    }
}
