// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

public class GetDramaChannelRequest {
    @SerializedName("user_id")
    public final String userId;
    // 客户需实现的建议扩展；VideoOne 服务端当前不会返回入口集。
    // Proposed extension requiring customer server work; VideoOne does not return entries today.
    @SerializedName("include_entry_episode")
    public final Boolean includeEntryEpisode;
    @SerializedName("format")
    public final Integer format;
    @SerializedName("codec")
    public final Integer codec;
    @SerializedName("fileType")
    public final String fileType;

    public GetDramaChannelRequest() {
        userId = null;
        includeEntryEpisode = null;
        format = null;
        codec = null;
        fileType = null;
    }

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
