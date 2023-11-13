// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.bytedance.voddemo.data.remote.api2;


import androidx.annotation.NonNull;

import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.data.page.Page;
import com.bytedance.voddemo.data.remote.RemoteApi;
import com.bytedance.voddemo.data.remote.RemoteApi.Callback;
import com.bytedance.voddemo.data.remote.RemoteApi.HandlerCallback;
import com.bytedance.voddemo.data.remote.api2.model.GetFeedStreamRequest;
import com.bytedance.voddemo.data.remote.api2.model.GetFeedStreamResponse;
import com.bytedance.voddemo.data.remote.api2.model.VideoDetail;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import retrofit2.Call;
import retrofit2.Response;

public class GetFeedStreamApi implements RemoteApi.GetFeedStream {

    private final List<Call<?>> mCalls = Collections.synchronizedList(new ArrayList<>());

    @Override
    public void getFeedStream(@RemoteApi.VideoType int videoType, String account, int pageIndex, int pageSize, Callback<Page<VideoItem>> callback) {
        final HandlerCallback<Page<VideoItem>> mainCallback = new HandlerCallback<>(callback);
        final GetFeedStreamRequest request = createRequest(
                videoType,
                account,
                pageIndex,
                pageSize
        );
        Call<GetFeedStreamResponse> call = createGetFeedStreamCall(request);
        call.enqueue(new retrofit2.Callback<GetFeedStreamResponse>() {
            @Override
            public void onResponse(@NonNull Call<GetFeedStreamResponse> call, @NonNull Response<GetFeedStreamResponse> response) {
                mCalls.remove(call);
                if (response.isSuccessful()) {
                    GetFeedStreamResponse result = response.body();
                    if (result == null) {
                        mainCallback.onError(new IOException("GetFeedStreamResponse is null"));
                        return;
                    }
                    if (result.hasError()) {
                        mainCallback.onError(new IOException("GetFeedStreamResponse has error: " + result.getError()));
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
                    mainCallback.onSuccess(new Page<>(items, pageIndex, Page.TOTAL_INFINITY));
                } else {
                    mainCallback.onError(new IOException("Response is not Successful: " + response.code()));
                }
            }

            @Override
            public void onFailure(@NonNull Call<GetFeedStreamResponse> call, @NonNull Throwable t) {
                mCalls.remove(call);
                mainCallback.onError(new IOException("GetFeedStream on failure", t));
            }
        });
        mCalls.add(call);
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
        for (Call<?> call : mCalls) {
            call.cancel();
        }
        mCalls.clear();
    }

    public static GetFeedStreamRequest createRequest(@RemoteApi.VideoType int videoType, String account, int pageIndex, int pageSize) {
        return new GetFeedStreamRequest(
                videoType,
                account,
                pageIndex * pageSize,
                pageSize,
                Params.Value.format(),
                Params.Value.codec(),
                Params.Value.definition(),
                Params.Value.fileType(),
                Params.Value.needThumbs(),
                Params.Value.enableBarrageMask(),
                Params.Value.cdnType(),
                Params.Value.unionInfo()
        );
    }
}
