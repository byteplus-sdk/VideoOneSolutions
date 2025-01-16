// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote;


import androidx.annotation.NonNull;

import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.base.CallMemories;
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
import com.vertcdemo.core.SolutionDataManager;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class GetDramas extends CallMemories {

    public void getDramaChannel(HttpCallback<DramaTheaterEntity> callback) {
        GetDramaChannelRequest request = new GetDramaChannelRequest();
        Call<ServerReturnResponse<DramaTheaterEntity>> call = remember(MiniDramaServer.dramaApi().getDramaChannel(request));
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(
                    @NonNull Call<ServerReturnResponse<DramaTheaterEntity>> call,
                    @NonNull Response<ServerReturnResponse<DramaTheaterEntity>> response
            ) {
                forget(call);

                if (response.isSuccessful()) {
                    ServerReturnResponse<DramaTheaterEntity> serverReturn = response.body();
                    if (serverReturn == null || !serverReturn.isSuccessful()) {
                        onFailure(call, new IOException("not successful"));
                        return;
                    }
                    callback.onSuccess(serverReturn.response);
                } else {
                    onFailure(call, new IOException("isSuccessful() = false"));
                }
            }

            @Override
            public void onFailure(
                    @NonNull Call<ServerReturnResponse<DramaTheaterEntity>> call,
                    @NonNull Throwable throwable
            ) {
                forget(call);
                callback.onError(throwable);
            }
        });
    }

    public void getDramaRecommend(int pageIndex, int pageSize, HttpCallback<List<DramaRecommend>> callback) {
        int offset = pageIndex * pageSize;
        GetDramaRecommendRequest request = new GetDramaRecommendRequest(offset, pageSize);
        Call<ServerReturnResponse<List<DramaRecommend>>> call = remember(MiniDramaServer.dramaApi().getDramaRecommend(request));
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(
                    @NonNull Call<ServerReturnResponse<List<DramaRecommend>>> call,
                    @NonNull Response<ServerReturnResponse<List<DramaRecommend>>> response
            ) {
                forget(call);

                if (response.isSuccessful()) {
                    ServerReturnResponse<List<DramaRecommend>> serverReturn = response.body();
                    if (serverReturn == null || !serverReturn.isSuccessful()) {
                        onFailure(call, new IOException("not successful"));
                        return;
                    }

                    List<DramaRecommend> dramas = serverReturn.response;
                    if (dramas == null) {
                        dramas = Collections.emptyList();
                    }
                    callback.onSuccess(dramas);
                } else {
                    onFailure(call, new IOException("isSuccessful() = false"));
                }
            }

            @Override
            public void onFailure(
                    @NonNull Call<ServerReturnResponse<List<DramaRecommend>>> call,
                    @NonNull Throwable throwable
            ) {
                forget(call);
                callback.onError(throwable);
            }
        });
    }

    public void getDramaList(@NonNull String dramaId, @NonNull HttpCallback<List<DramaFeed>> callback) {
        SolutionDataManager dataManager = SolutionDataManager.ins();
        DramaListRequest request = new DramaListRequest(dramaId, dataManager.getUserId());
        Call<ServerReturnResponse<List<DramaFeed>>> call = remember(MiniDramaServer.dramaApi().getDramaList(dataManager.getToken(), request));
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(
                    @NonNull Call<ServerReturnResponse<List<DramaFeed>>> call,
                    @NonNull Response<ServerReturnResponse<List<DramaFeed>>> response
            ) {
                forget(call);

                if (response.isSuccessful()) {
                    ServerReturnResponse<List<DramaFeed>> serverReturn = response.body();
                    if (serverReturn == null || !serverReturn.isSuccessful()) {
                        onFailure(call, new IOException("not successful"));
                        return;
                    }

                    List<DramaFeed> dramas = serverReturn.response;
                    if (dramas == null) {
                        dramas = Collections.emptyList();
                    }
                    patchDramaFeed(dramaId, dramas);
                    callback.onSuccess(dramas);
                } else {
                    onFailure(call, new IOException("isSuccessful() = false"));
                }
            }

            @Override
            public void onFailure(
                    @NonNull Call<ServerReturnResponse<List<DramaFeed>>> call,
                    @NonNull Throwable throwable
            ) {
                forget(call);
                callback.onError(throwable);
            }
        });
    }

    private static void patchDramaFeed(String dramaId, List<DramaFeed> list) {
        for (DramaFeed drama : list) {
            if (drama.dramaId == null) {
                drama.dramaId = dramaId;
            }
        }
    }

    public void unlockEpisodes(@NonNull String dramaId, List<String> episodes, @NonNull HttpCallback<List<DramaUnlockMeta>> callback) {
        SolutionDataManager dataManager = SolutionDataManager.ins();
        UnlockEpisodesRequest request = new UnlockEpisodesRequest(dramaId, episodes, dataManager.getUserId());
        Call<ServerReturnResponse<List<DramaUnlockMeta>>> call = remember(MiniDramaServer.dramaApi().unlockEpisodes(dataManager.getToken(), request));
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(
                    @NonNull Call<ServerReturnResponse<List<DramaUnlockMeta>>> call,
                    @NonNull Response<ServerReturnResponse<List<DramaUnlockMeta>>> response
            ) {
                forget(call);

                if (response.isSuccessful()) {
                    ServerReturnResponse<List<DramaUnlockMeta>> serverReturn = response.body();
                    if (serverReturn == null || !serverReturn.isSuccessful()) {
                        onFailure(call, new IOException("not successful"));
                        return;
                    }

                    List<DramaUnlockMeta> dramas = serverReturn.response;
                    if (dramas == null) {
                        dramas = Collections.emptyList();
                    }
                    callback.onSuccess(dramas);
                } else {
                    onFailure(call, new IOException("isSuccessful() = false"));
                }
            }

            @Override
            public void onFailure(
                    @NonNull Call<ServerReturnResponse<List<DramaUnlockMeta>>> call,
                    @NonNull Throwable throwable
            ) {
                forget(call);
                callback.onError(throwable);
            }
        });
    }

    public void getVideoComments(String vid, @NonNull HttpCallback<List<CommentDetail>> callback) {
        Call<ServerReturnResponse<List<CommentDetail>>> call = remember(MiniDramaServer.dramaApi().getVideoComments(vid));
        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(
                    @NonNull Call<ServerReturnResponse<List<CommentDetail>>> call,
                    @NonNull Response<ServerReturnResponse<List<CommentDetail>>> response
            ) {
                forget(call);

                if (response.isSuccessful()) {
                    ServerReturnResponse<List<CommentDetail>> serverReturn = response.body();
                    if (serverReturn == null || !serverReturn.isSuccessful()) {
                        onFailure(call, new IOException("not successful"));
                        return;
                    }

                    List<CommentDetail> dramas = serverReturn.response;
                    if (dramas == null) {
                        dramas = Collections.emptyList();
                    }
                    callback.onSuccess(dramas);
                } else {
                    onFailure(call, new IOException("isSuccessful() = false"));
                }
            }

            @Override
            public void onFailure(
                    @NonNull Call<ServerReturnResponse<List<CommentDetail>>> call,
                    @NonNull Throwable throwable
            ) {
                forget(call);
                callback.onError(throwable);
            }
        });
    }
}
