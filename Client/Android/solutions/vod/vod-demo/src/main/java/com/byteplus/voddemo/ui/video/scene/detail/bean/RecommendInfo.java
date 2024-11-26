// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.detail.bean;

import androidx.annotation.NonNull;

import com.byteplus.vodcommon.data.remote.RemoteApi;

public class RecommendInfo {
    @NonNull
    public final String vid;

    @RemoteApi.VideoType
    public final int videoType;

    public RecommendInfo(@NonNull String vid, @RemoteApi.VideoType int videoType) {
        this.vid = vid;
        this.videoType = videoType;
    }

    @NonNull
    @Override
    public String toString() {
        return "RecommendInfo{" +
                "vid='" + vid + '\'' +
                ", videoType=" + videoType +
                '}';
    }
}
