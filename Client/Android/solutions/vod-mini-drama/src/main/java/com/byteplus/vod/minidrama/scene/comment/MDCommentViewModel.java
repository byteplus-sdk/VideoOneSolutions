// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.minidrama.scene.comment;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vodcommon.data.remote.api2.model.CommentDetail;
import com.byteplus.vodcommon.ui.video.scene.comment.model.CommentItem;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MDCommentViewModel extends ViewModel {

    public enum State {
        INIT, LOADED, LOADING, ERROR
    }

    public String vid;

    public MutableLiveData<State> state = new MutableLiveData<>(State.INIT);

    public MutableLiveData<List<CommentItem>> comments = new MutableLiveData<>(Collections.emptyList());

    final GetDramas api = new GetDramas();

    public void load() {
        state.postValue(State.LOADING);
        api.getVideoComments(vid, new HttpCallback<>() {

            @Override
            public void onSuccess(List<CommentDetail> details) {
                List<CommentItem> items = new ArrayList<>();
                if (details != null) {
                    for (CommentDetail detail : details) {
                        items.add(detail.toItem());
                    }
                }
                comments.postValue(items);
                state.postValue(State.LOADED);
            }

            @Override
            public void onError(Throwable t) {
                state.postValue(State.ERROR);
            }
        });
    }

    @Override
    protected void onCleared() {
        api.cancel();
        super.onCleared();
    }
}
