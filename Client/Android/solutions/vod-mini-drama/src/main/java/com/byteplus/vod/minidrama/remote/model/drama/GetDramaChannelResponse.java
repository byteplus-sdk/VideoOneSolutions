// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GetDramaChannelResponse {
    @SerializedName(value = "loop")
    public List<DramaInfo> loop;
    @SerializedName(value = "trending")
    public List<DramaInfo> trending;
    @SerializedName(value = "new")
    public List<DramaInfo> news;
    @SerializedName(value = "recommend")
    public List<DramaInfo> recommend;
}
