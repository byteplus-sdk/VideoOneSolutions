// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

public class GetDramaRecommendRequest {
    @SerializedName("offset")
    public final int offset;
    @SerializedName("page_size")
    public final int pageSize;
    @SerializedName("format")
    public final Integer format;
    @SerializedName("codec")
    public final Integer codec;
    @SerializedName("file_type")
    public final String fileType;

    public GetDramaRecommendRequest(int offset, int pageSize, Integer format, Integer codec, String fileType) {
        this.offset = offset;
        this.pageSize = pageSize;
        this.format = format;
        this.codec = codec;
        this.fileType = fileType;
    }
}
