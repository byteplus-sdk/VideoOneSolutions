/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.voddemo.ui.video.scene.comment;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.bytedance.voddemo.ui.video.scene.comment.model.CommentItem;
import com.bytedance.voddemo.data.remote.api2.ApiManager;
import com.bytedance.voddemo.data.remote.api2.model.CommentDetail;
import com.bytedance.voddemo.data.remote.api2.model.GetVideoCommentResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class CommentViewModel extends ViewModel {

    enum State {
        INIT, LOADED, LOADING, ERROR
    }

    public String vid;

    public MutableLiveData<State> state = new MutableLiveData<>(State.INIT);

    public MutableLiveData<List<CommentItem>> comments = new MutableLiveData<>(Collections.emptyList());

    public void load() {
        state.postValue(State.LOADING);
        ApiManager.api2().getVideoComments(vid).enqueue(new Callback<GetVideoCommentResponse>() {
            @Override
            public void onResponse(@NonNull Call<GetVideoCommentResponse> call, @NonNull Response<GetVideoCommentResponse> response) {
                if (response.isSuccessful()) {
                    GetVideoCommentResponse result = response.body();
                    if (result == null) {
                        onFailure(call, new IOException("Server Response is null"));
                        return;
                    }
                    if (result.hasError()) {
                        onFailure(call, new IOException("Server Response has Error: " + result.getError()));
                        return;
                    }
                    List<CommentDetail> details = result.result;
                    List<CommentItem> items = new ArrayList<>();
                    if (details != null) {
                        for (CommentDetail detail : details) {
                            items.add(detail.toItem());
                        }
                    }
                    comments.postValue(items);
                    state.postValue(State.LOADED);
                } else {
                    onFailure(call, new IOException("Response.is NOT Successful: " + response.code()));
                }
            }

            @Override
            public void onFailure(@NonNull Call<GetVideoCommentResponse> call, @NonNull Throwable t) {
                state.postValue(State.ERROR);
            }
        });
    }
}
