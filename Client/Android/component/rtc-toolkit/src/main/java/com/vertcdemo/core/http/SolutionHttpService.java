// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.vertcdemo.core.SolutionDataManager;

import java.util.Objects;

public abstract class SolutionHttpService {

    private String mAppId;

    public void setAppId(@NonNull String appId) {
        mAppId = appId;
    }

    /**
     * Get common request parameters for RTC service.
     *
     * @return common parameters
     */
    protected JsonObject getCommonParams() {
        String appId = Objects.requireNonNull(mAppId, "No RTC AppId provided.");

        JsonObject params = new JsonObject();
        params.addProperty("app_id", appId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        params.addProperty("device_id", SolutionDataManager.ins().getDeviceId());
        return params;
    }

    protected void request(@NonNull String eventName,
                           @NonNull JsonObject params,
                           @NonNull Callback<Void> callback) {
        request(eventName, params, Void.class, callback);
    }

    protected <T> void request(@NonNull String eventName,
                               @NonNull JsonObject content,
                               @Nullable Class<T> type,
                               @NonNull Callback<T> callback) {
        String token = Objects.requireNonNull(SolutionDataManager.ins().getToken());

        HttpClient.request(eventName, token, content, type, callback);
    }
}
