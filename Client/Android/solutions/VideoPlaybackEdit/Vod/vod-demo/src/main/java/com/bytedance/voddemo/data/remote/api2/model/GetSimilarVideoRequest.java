// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;

import com.bytedance.voddemo.data.remote.RemoteApi;
import com.google.gson.annotations.SerializedName;

public class GetSimilarVideoRequest {
    @SerializedName("vid")
    public String vid;

    @RemoteApi.VideoType
    @SerializedName("videoType")
    public int videoType;
    @SerializedName("offset")
    public int offset;
    @SerializedName("pageSize")
    public int pageSize;

    public GetSimilarVideoRequest(String vid, @RemoteApi.VideoType int videoType, int offset, int pageSize) {
        this.vid = vid;
        this.videoType = videoType;
        this.offset = offset;
        this.pageSize = pageSize;
    }
}
