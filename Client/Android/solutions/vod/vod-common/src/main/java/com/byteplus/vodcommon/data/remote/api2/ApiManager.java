// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2;

import com.byteplus.vodcommon.BuildConfig;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamRequest;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetPlaylistResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetSimilarVideoRequest;
import com.byteplus.vodcommon.data.remote.api2.model.GetVideoCommentResponse;
import com.vertcdemo.core.net.HttpClient;

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
        api2 = new Retrofit.Builder()
                .baseUrl(BuildConfig.VOD_BASE_URL)
                .client(HttpClient.getClient())
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
}
