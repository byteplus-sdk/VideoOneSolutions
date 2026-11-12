// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import android.text.TextUtils;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

/**
 * 建议由客户首页返回的入口模型；VideoOne 当前服务端尚未实现。
 * Proposed customer-feed entry model; the current VideoOne server does not implement it.
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

    // 仅标记本地逐剧查询的模拟结果，不作为网络字段或持久化数据。
    // Marks local per-drama simulation only; never a wire field or persisted value.
    public transient boolean demoFallback;

    // 有效期使用 Unix 毫秒时间；未返回有效期时，不在业务层判定过期。
    // Expiry uses Unix epoch milliseconds; an omitted expiry does not fail this app-side check.
    public boolean isUsable(long nowMs) {
        return feed != null
                && !TextUtils.isEmpty(feed.vid)
                && !TextUtils.isEmpty(feed.playAuthToken)
                && feed.episodeNumber > 0
                && !feed.isLocked()
                && (authExpireAtMs <= 0 || authExpireAtMs > nowMs);
    }

    @Nullable
    public String getMediaId() {
        return feed == null ? null : feed.vid;
    }
}
