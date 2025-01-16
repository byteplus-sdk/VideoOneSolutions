// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

public class GetDramaRecommendRequest {
    @SerializedName("offset")
    public final int offset;
    @SerializedName("page_size")
    public final int pageSize;

    public GetDramaRecommendRequest(int offset, int pageSize) {
        this.offset = offset;
        this.pageSize = pageSize;
    }
}
