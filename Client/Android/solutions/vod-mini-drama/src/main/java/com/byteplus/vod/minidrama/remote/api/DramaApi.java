// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.api;

import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.remote.model.drama.DramaListRequest;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterEntity;
import com.byteplus.vod.minidrama.remote.model.drama.DramaUnlockMeta;
import com.byteplus.vod.minidrama.remote.model.drama.GetDramaChannelRequest;
import com.byteplus.vod.minidrama.remote.model.drama.GetDramaRecommendRequest;
import com.byteplus.vod.minidrama.remote.model.drama.ServerReturnResponse;
import com.byteplus.vod.minidrama.remote.model.drama.UnlockEpisodesRequest;
import com.byteplus.vodcommon.data.remote.api2.model.CommentDetail;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface DramaApi {
    @POST("drama/v1/getDramaChannel")
    Call<ServerReturnResponse<DramaTheaterEntity>> getDramaChannel(@Body GetDramaChannelRequest request);

    @POST("drama/v1/getDramaFeed")
    Call<ServerReturnResponse<List<DramaRecommend>>> getDramaRecommend(@Body GetDramaRecommendRequest request);

    @POST("drama/v1/getDramaList")
    Call<ServerReturnResponse<List<DramaFeed>>> getDramaList(
            @Header("X-Login-Token") String loginToken,
            @Body DramaListRequest request
    );

    @POST("drama/v1/getDramaDetail")
    Call<ServerReturnResponse<List<DramaUnlockMeta>>> unlockEpisodes(
            @Header("X-Login-Token") String loginToken, @Body UnlockEpisodesRequest request
    );

    @GET("drama/v1/getVideoComments")
    Call<ServerReturnResponse<List<CommentDetail>>> getVideoComments(@Query("vid") String vid);
}
