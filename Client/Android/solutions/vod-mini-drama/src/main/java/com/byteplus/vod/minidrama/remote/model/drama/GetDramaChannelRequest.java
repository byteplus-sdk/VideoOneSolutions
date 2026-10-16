// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

public class GetDramaChannelRequest {
    @SerializedName("user_id")
    public final String userId;
    @SerializedName("include_entry_episode")
    public final boolean includeEntryEpisode;
    @SerializedName("format")
    public final Integer format;
    @SerializedName("codec")
    public final Integer codec;
    @SerializedName("fileType")
    public final String fileType;

    public GetDramaChannelRequest(String userId,
                                  boolean includeEntryEpisode,
                                  Integer format,
                                  Integer codec,
                                  String fileType) {
        this.userId = userId;
        this.includeEntryEpisode = includeEntryEpisode;
        this.format = format;
        this.codec = codec;
        this.fileType = fileType;
    }
}
