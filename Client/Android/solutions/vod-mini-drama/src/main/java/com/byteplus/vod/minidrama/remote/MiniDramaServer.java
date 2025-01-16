// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote;

import com.byteplus.vod.minidrama.remote.api.DramaApi;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.vertcdemo.base.BuildConfig;
import com.vertcdemo.core.net.HttpClient;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class MiniDramaServer {

    private final DramaApi mDramaApi;

    private MiniDramaServer() {
        Gson gson = new GsonBuilder()
                .create();

        mDramaApi = new Retrofit.Builder()
                .baseUrl(BuildConfig.SERVER_URL + "/")
                .client(HttpClient.getClient())
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build()
                .create(DramaApi.class);
    }

    private static class Holder {
        private static final MiniDramaServer sInstance = new MiniDramaServer();
    }

    public static DramaApi dramaApi() {
        return Holder.sInstance.mDramaApi;
    }
}
