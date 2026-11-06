// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

/**
 * 首页返回的首播或续播入口，包含播放数据、续播位置和凭证有效期。
 * Home-feed entry for first or resumed playback, with media data, resume position and auth expiry.
 */
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

    // 有效期使用 Unix 毫秒时间；未返回有效期时，不在业务层判定过期。
    // Expiry uses Unix epoch milliseconds; an omitted expiry does not fail this app-side check.
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
