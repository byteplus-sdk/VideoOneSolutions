// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload;

import android.app.Application;
import android.util.Log;

import androidx.annotation.NonNull;

import com.byteplus.vodupload.model.UploadResponseModel;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.ss.bduploader.BDVideoInfo;
import com.ss.bduploader.BDVideoUploader;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.GET;
import retrofit2.http.Query;

public class UploadApi {
    private static final String TAG = "UploadApi";

    private static final String BASE_URL = BuildConfig.SERVER_URL + "/vod/v1/";
    private final Api mApi;

    public static UploadApi getInstance() {
        return Holder.sInstance;
    }

    private static class Holder {
        private static final UploadApi sInstance = new UploadApi();
    }

    private UploadApi() {
        OkHttpClient httpClient = new OkHttpClient
                .Builder()
                .connectTimeout(60, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(60, TimeUnit.SECONDS)
                .build();
        mApi = new Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(httpClient)
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                .create(Api.class);
    }

    public void init(Application context, String appID, String appName, String appVersion, String appChannel) {
        Env.init(new Config.Builder()
                .setApplicationContext(context)
                .setAppID(appID)
                .setAppName(appName)
                .setAppVersion(appVersion)
                .setAppChannel(appChannel)
                .build());
    }

    public void startUpload(String filePath,
                            String fileExtension,
                            String filePrefix,
                            int expiredMin,
                            @NonNull IUploadListener listener) {
        mApi.getUploadInfo(expiredMin)
                .enqueue(new Callback<UploadResponseModel>() {
                    @Override
                    public void onResponse(@NonNull Call<UploadResponseModel> call, @NonNull Response<UploadResponseModel> response) {
                        UploadResponseModel body = response.body();
                        Log.d(TAG, "[onResponse] body=" + body);
                        if (body == null || body.body == null || body.body.isInvalid()) {
                            listener.onError("Get upload info failed!");
                            return;
                        }
                        BDVideoUploader uploader = createUploader(body.body, fileExtension, filePrefix, filePath, listener);
                        if (uploader == null) {
                            listener.onError("Video Uploader create failed!");
                            return;
                        }
                        uploader.start();
                    }

                    @Override
                    public void onFailure(@NonNull Call<UploadResponseModel> call, @NonNull Throwable t) {
                        Log.d(TAG, "onFailure", t);
                        listener.onError("Get upload info failed!");
                    }
                });
    }

    private BDVideoUploader createUploader(UploadResponseModel.Body body, String fileExtension,
                                           String filePrefix, String filePath,
                                           @NonNull IUploadListener listener) {
        BDVideoUploader uploader;
        try {
            uploader = new BDVideoUploader();
        } catch (Exception e) {
            Log.d(TAG, "[createUploader] failed", e);
            return null;
        }

        uploader.setTopAccessKey(body.accessKeyID);
        uploader.setTopSecretKey(body.secretAccessKey);
        uploader.setTopSessionToken(body.sessionToken);
        uploader.setSpaceName(body.spaceName);
        uploader.setFileExtension(fileExtension);
        uploader.setFilePrefix(filePrefix);
        uploader.setPathName(filePath);

        uploader.setListener(new BDVideoUploaderAdapter() {
            @Override
            public void onNotify(int what, long parameter, BDVideoInfo info) {
                if (what == BDVideoUploader.MsgIsComplete) {
                    listener.onUploadSuccess();
                } else if (what == BDVideoUploader.MsgIsFail) {
                    listener.onError("Upload failed!");
                } else if (what == BDVideoUploader.MsgIsUpdateProgress) {
                    listener.onUploadProgress((int) parameter); // 0 ~ 100
                }
            }
        });
        return uploader;
    }

    interface Api {
        @GET("upload")
        Call<UploadResponseModel> getUploadInfo(
                @Query("expiredTime") int expiredTimeInMinutes
        );
    }
}
