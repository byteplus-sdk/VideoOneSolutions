// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.video.scene.detail;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.voddemo.ui.video.scene.detail.bean.RecommendInfo;

public class DetailViewModel extends ViewModel {
    public final MutableLiveData<RecommendInfo> recommendInfo = new MutableLiveData<>();
    public MutableLiveData<VideoItem> recommendVideoItem = new MutableLiveData<>();

    public void updateRecommendInfoVid(@NonNull String vid) {
        RecommendInfo old = recommendInfo.getValue();
        if (old == null) {
            return;
        }
        recommendInfo.setValue(new RecommendInfo(vid, old.videoType));
    }
}