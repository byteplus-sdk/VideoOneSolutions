// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.http;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.net.SolutionRetrofit;

import retrofit2.Call;
import retrofit2.Response;

class HttpClient {
    private static IHttpClient httpClient;

    public static <T> void request(@NonNull String eventName,
                                   @NonNull String loginToken,
                                   @NonNull JsonObject content,
                                   @Nullable Class<T> type,
                                   @NonNull Callback<T> callback) {
        if (httpClient == null) {
            httpClient = SolutionRetrofit.getApi(IHttpClient.class);
        }
        httpClient.post(eventName, loginToken, content)
                .enqueue(new retrofit2.Callback<String>() {
                    @Override
                    public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                        String element = response.body();
                        if (type == null || type == Void.class || element == null) {
                            callback.onResponse(null);
                        } else {
                            T result = GsonUtils.gson().fromJson(element, type);
                            callback.onResponse(result);
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                        callback.onFailure(HttpException.of(t));
                    }
                });
    }
}
