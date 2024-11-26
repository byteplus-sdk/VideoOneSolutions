// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vodcommon.data.remote.api2;


import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.byteplus.vodcommon.data.remote.RemoteApi.Callback;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamRequest;
import com.byteplus.vodcommon.data.remote.api2.model.GetFeedStreamResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetPlaylistResponse;
import com.byteplus.vodcommon.data.remote.api2.model.GetSimilarVideoRequest;
import com.byteplus.vodcommon.data.remote.api2.model.VideoDetail;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Response;

public class GetFeedStreamApi extends CallManager implements RemoteApi.GetFeedStream {

    @Override
    public void getFeedStream(@RemoteApi.VideoType int videoType,
                              String account,
                              int pageIndex,
                              int pageSize,
                              @NonNull Callback<Page<VideoItem>> callback) {
        final GetFeedStreamRequest request = createRequest(
                videoType,
                account,
                pageIndex,
                pageSize
        );
        getFeedStream(request, pageIndex, callback);
    }

    public void getFeedStream(@NonNull GetFeedStreamRequest request,
                              @NonNull Callback<Page<VideoItem>> callback) {
        getFeedStream(request, 0, callback);
    }

    public void getPlaylistStream(@NonNull Callback<Page<VideoItem>> callback) {

        Call<GetPlaylistResponse> call = remember(ApiManager.api2().getPlaylistDetail());
        call.enqueue(new retrofit2.Callback<GetPlaylistResponse>() {
            @Override
            public void onResponse(@NonNull Call<GetPlaylistResponse> call, @NonNull Response<GetPlaylistResponse> response) {
                forget(call);
                if (response.isSuccessful()) {
                    GetPlaylistResponse result = response.body();
                    if (result == null || result.playlistDetail == null
                            || result.playlistDetail.videoList == null
                            || result.playlistDetail.videoList.isEmpty()) {
                        callback.onError(new IOException("GetPlaylistStreamResponse is null"));
                        return;
                    }
                    if (result.hasError()) {
                        callback.onError(new IOException("GetPlaylistStreamResponse has error: " + result.getError()));
                        return;
                    }
                    List<VideoDetail> details = result.playlistDetail.videoList;
                    List<VideoItem> items = new ArrayList<>();
                    if (details != null) {
                        for (VideoDetail detail : details) {
                            VideoItem item = VideoDetail.toVideoItem(detail);
                            if (item != null) {
                                items.add(item);
                            }
                        }
                    }
                    callback.onSuccess(new Page<>(items, result.playlistDetail.playMode));
                } else {
                    callback.onError(new IOException("Response is not Successful: " + response.code()));
                }
            }

            @Override
            public void onFailure(@NonNull Call<GetPlaylistResponse> call, @NonNull Throwable t) {
                forget(call);
                callback.onError(new IOException("GetPlaylistStream on failure", t));
            }
        });
    }

    public void getFeedStream(@NonNull GetFeedStreamRequest request,
                              int pageIndex,
                              @NonNull Callback<Page<VideoItem>> callback) {

        Call<GetFeedStreamResponse> call = remember(createGetFeedStreamCall(request));
        call.enqueue(new retrofit2.Callback<GetFeedStreamResponse>() {
            @Override
            public void onResponse(@NonNull Call<GetFeedStreamResponse> call, @NonNull Response<GetFeedStreamResponse> response) {
                forget(call);
                if (response.isSuccessful()) {
                    GetFeedStreamResponse result = response.body();
                    if (result == null) {
                        callback.onError(new IOException("GetFeedStreamResponse is null"));
                        return;
                    }
                    if (result.hasError()) {
                        callback.onError(new IOException("GetFeedStreamResponse has error: " + result.getError()));
                        return;
                    }
                    List<VideoDetail> details = result.result;
                    List<VideoItem> items = new ArrayList<>();
                    if (details != null) {
                        for (VideoDetail detail : details) {
                            VideoItem item = VideoDetail.toVideoItem(detail);
                            if (item != null) {
                                items.add(item);
                            }
                        }
                    }
                    callback.onSuccess(new Page<>(items, pageIndex, Page.TOTAL_INFINITY));
                } else {
                    callback.onError(new IOException("Response is not Successful: " + response.code()));
                }
            }

            @Override
            public void onFailure(@NonNull Call<GetFeedStreamResponse> call, @NonNull Throwable t) {
                forget(call);
                callback.onError(new IOException("GetFeedStream on failure", t));
            }
        });
    }

    public void getFeedSimilarVideos(String vid,
                                     @RemoteApi.VideoType int videoType,
                                     int pageIndex,
                                     int pageSize,
                                     @NonNull Callback<Page<VideoItem>> callback) {

        final GetSimilarVideoRequest request = createSimilarVideoRequest(
                vid,
                videoType,
                pageIndex,
                pageSize
        );
        Call<GetFeedStreamResponse> call = remember(createSimilarVideoVideoCall(request));
        call.enqueue(new retrofit2.Callback<GetFeedStreamResponse>() {
            @Override
            public void onResponse(@NonNull Call<GetFeedStreamResponse> call, @NonNull Response<GetFeedStreamResponse> response) {
                forget(call);
                if (response.isSuccessful()) {
                    GetFeedStreamResponse result = response.body();
                    if (result == null) {
                        callback.onError(new IOException("GetFeedStreamResponse is null"));
                        return;
                    }
                    if (result.hasError()) {
                        callback.onError(new IOException("GetFeedStreamResponse has error: " + result.getError()));
                        return;
                    }
                    List<VideoDetail> details = result.result;
                    List<VideoItem> items = new ArrayList<>();
                    if (details != null) {
                        for (VideoDetail detail : details) {
                            VideoItem item = VideoDetail.toVideoItem(detail);
                            if (item != null) {
                                items.add(item);
                            }
                        }
                    }
                    callback.onSuccess(new Page<>(items, pageIndex, Page.TOTAL_INFINITY));
                } else {
                    callback.onError(new IOException("Response is not Successful: " + response.code()));
                }
            }

            @Override
            public void onFailure(@NonNull Call<GetFeedStreamResponse> call, @NonNull Throwable t) {
                forget(call);
                callback.onError(new IOException("GetFeedStream on failure", t));
            }
        });
    }

    protected Call<GetFeedStreamResponse> createGetFeedStreamCall(GetFeedStreamRequest request) {
        final int sourceType = VideoSettings.intValue(VideoSettings.COMMON_SOURCE_TYPE);
        switch (sourceType) {
            case VideoSettings.SourceType.SOURCE_TYPE_VID:
                return ApiManager.api2().getFeedStreamWithPlayAuthToken(request);
            case VideoSettings.SourceType.SOURCE_TYPE_URL:
            case VideoSettings.SourceType.SOURCE_TYPE_MODEL:
                return ApiManager.api2().getFeedVideoStreamWithVideoModel(request);
            default:
                throw new IllegalArgumentException("Unsupported sourceType: " + sourceType);
        }
    }

    @Override
    public void cancel() {
        forget();
    }

    static Call<GetFeedStreamResponse> createSimilarVideoVideoCall(GetSimilarVideoRequest request) {
        return ApiManager.api2().getSimilarVideoWithPlayAuthToken(request);
    }

    static GetFeedStreamRequest createRequest(@RemoteApi.VideoType int videoType,
                                              String account,
                                              int pageIndex,
                                              int pageSize) {
        return new GetFeedStreamRequest(
                videoType,
                account,
                pageIndex * pageSize,
                pageSize,
                Params.Value.format(),
                Params.Value.codec()
        );
    }

    static GetSimilarVideoRequest createSimilarVideoRequest(String vid,
                                                            @RemoteApi.VideoType int videoType,
                                                            int pageIndex,
                                                            int pageSize) {
        return new GetSimilarVideoRequest(
                vid,
                videoType,
                pageIndex * pageSize,
                pageSize
        );
    }
}
