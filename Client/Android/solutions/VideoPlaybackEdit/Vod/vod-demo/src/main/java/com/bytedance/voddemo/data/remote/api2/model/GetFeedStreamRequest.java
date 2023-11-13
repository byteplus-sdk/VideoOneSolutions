// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;


import com.bytedance.voddemo.data.remote.RemoteApi;
import com.google.gson.annotations.SerializedName;

public class GetFeedStreamRequest {
    @SerializedName("videoType")
    @RemoteApi.VideoType
    private final int videoType;
    private final String userID;
    private final Integer offset;
    private final Integer pageSize;
    private final Integer format;
    private final Integer codec;
    private final Integer definition;
    private final String fileType;
    private final Boolean needThumbs;
    private final Boolean needBarrageMask;
    private final Integer cdnType;
    private final String UnionInfo;

    public GetFeedStreamRequest(@RemoteApi.VideoType int videoType,
                                final String userID,
                                final Integer offset,
                                final Integer pageSize,
                                final Integer format,
                                final Integer codec,
                                final Integer definition,
                                final String fileType,
                                final Boolean needThumbs,
                                final Boolean needBarrageMask,
                                final Integer cdnType,
                                final String unionInfo) {
        this.videoType = videoType;
        this.userID = userID;
        this.offset = offset;
        this.pageSize = pageSize;
        this.format = format;
        this.codec = codec;
        this.definition = definition;
        this.fileType = fileType;
        this.needThumbs = needThumbs;
        this.needBarrageMask = needBarrageMask;
        this.cdnType = cdnType;
        this.UnionInfo = unionInfo;
    }
}
