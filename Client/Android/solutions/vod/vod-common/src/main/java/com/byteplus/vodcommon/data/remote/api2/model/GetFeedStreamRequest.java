// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2.model;


import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.google.gson.annotations.SerializedName;

public class GetFeedStreamRequest {
    @SerializedName("videoType")
    @RemoteApi.VideoType
    private final int videoType;
    @SerializedName("userID")
    private final String userID;
    @SerializedName("offset")
    private final Integer offset;
    @SerializedName("pageSize")
    private final Integer pageSize;
    @SerializedName("format")
    private final Integer format;
    @SerializedName("codec")
    private final Integer codec;

    @SerializedName("supportSmartSubtitle")
    public Boolean supportSmartSubtitle = null;

    @SerializedName("antiScreenshotAndRecord")
    public Boolean antiScreenshotAndRecord = null;

    public GetFeedStreamRequest(@RemoteApi.VideoType int videoType,
                                final String userID,
                                final Integer offset,
                                final Integer pageSize,
                                final Integer format,
                                final Integer codec) {
        this.videoType = videoType;
        this.userID = userID;
        this.offset = offset;
        this.pageSize = pageSize;
        this.format = format;
        this.codec = codec;
    }
}
