// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2;

import android.util.Log;

import com.byteplus.vodcommon.BuildConfig;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamRequest;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetPlaylistResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetSimilarVideoRequest;
import com.byteplus.vodcommon.data.remote.api2.model.GetVideoCommentResponse;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;

public class ApiManager {
    private static final boolean DEBUG_LOG = false;
    private static final String TAG = "ApiManager";
    private final Api2 api2;

    private ApiManager() {
        OkHttpClient httpClient = builder()
                .connectTimeout(60, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(60, TimeUnit.SECONDS)
                .build();
        api2 = new Retrofit.Builder()
                .baseUrl(BuildConfig.VOD_BASE_URL)
                .client(httpClient)
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                .create(Api2.class);
    }

    private static class Holder {
        private static final ApiManager sInstance = new ApiManager();
    }

    public static Api2 api2() {
        return Holder.sInstance.api2;
    }

    public interface Api2 {
        @POST("getFeedStreamWithPlayAuthToken")
        Call<GetFeedStreamResponse> getFeedStreamWithPlayAuthToken(@Body GetFeedStreamRequest request);

        @POST("getFeedStreamWithVideoModel")
        Call<GetFeedStreamResponse> getFeedVideoStreamWithVideoModel(@Body GetFeedStreamRequest request);

        @POST("getFeedSimilarVideos")
        Call<GetFeedStreamResponse> getSimilarVideoWithPlayAuthToken(@Body GetSimilarVideoRequest request);

        @POST("getPlayListDetail")
        Call<GetPlaylistResponse> getPlaylistDetail();

        @GET("getVideoComments")
        Call<GetVideoCommentResponse> getVideoComments(@Query("vid") String vid);
    }

    private static OkHttpClient.Builder builder() {
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        if (DEBUG_LOG) {
            HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor(message -> Log.d(TAG, message));
            interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
            builder.addInterceptor(interceptor);
        }
        return builder;
    }
}
