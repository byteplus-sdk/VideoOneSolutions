// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.recommend;

import android.text.TextUtils;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;

import java.util.List;

public class RecommendForYouViewModel extends ViewModel {
    private static final int PAGE_SIZE = 5;

    public enum State {
        INIT, LOADED, LOADING, ERROR
    }

    private final GetDramas api = new GetDramas();

    public DramaInfo dramaInfo;
    public int episodeNumber;

    public boolean isSelected(DramaRecommend recommend) {
        if (recommend.info == null || recommend.feed == null
                || dramaInfo == null) {
            return false;
        }

        return recommend.feed.episodeNumber == episodeNumber
                && TextUtils.equals(recommend.info.dramaId, dramaInfo.dramaId);
    }

    public final MutableLiveData<State> state = new MutableLiveData<>(State.INIT);

    public final MutableLiveData<List<DramaRecommend>> recommends = new MutableLiveData<>();

    public void load() {
        state.postValue(State.LOADING);
        api.getDramaRecommend(0, PAGE_SIZE, new HttpCallback<>() {
            @Override
            public void onSuccess(List<DramaRecommend> items) {
                state.postValue(State.LOADED);
                recommends.postValue(items);
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
