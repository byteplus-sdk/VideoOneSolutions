// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

public class DramaListRequest {
    @SerializedName("user_id")
    public final String userId;
    @SerializedName("drama_id")
    public final String dramaId;

    public DramaListRequest(String dramaId, String userId) {
        this.dramaId = dramaId;
        this.userId = userId;
    }
}
