// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http;

import com.google.gson.JsonObject;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Query;

interface IHttpClient {
    @POST("http_call")
    Call<String> post(
            @Query("event_name") String eventName,
            @Header("X-Login-Token") String loginToken,
            @Body JsonObject body
    );
}
