// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.Nullable;

import java.util.List;

public class UnlockEpisodesRequest {
    @SerializedName("user_id")
    public final String userId;
    @SerializedName("drama_id")
    public final String dramaId;
    @SerializedName("vid_list")
    public final List<String> episodeIds;

    public UnlockEpisodesRequest(String dramaId, List<String> episodes, @Nullable String userId) {
        this.dramaId = dramaId;
        this.episodeIds = episodes;
        this.userId = userId;
    }
}
