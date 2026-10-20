// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class DramaEntryEpisode implements Serializable {
    public static final String REASON_FIRST_PLAY = "FIRST_PLAY";
    public static final String REASON_CONTINUE_PLAY = "CONTINUE_PLAY";

    @SerializedName("reason")
    public String reason;
    @SerializedName("feed")
    public DramaFeed feed;
    @SerializedName("resume_position_ms")
    public long resumePositionMs;
    @SerializedName("history_updated_at_ms")
    public long historyUpdatedAtMs;
    @SerializedName("auth_expire_at_ms")
    public long authExpireAtMs;

    public boolean isUsable(long nowMs) {
        return feed != null
                && feed.episodeNumber > 0
                && !feed.isLocked()
                && (authExpireAtMs <= 0 || authExpireAtMs > nowMs);
    }

    @Nullable
    public String getMediaId() {
        return feed == null ? null : feed.vid;
    }
}
