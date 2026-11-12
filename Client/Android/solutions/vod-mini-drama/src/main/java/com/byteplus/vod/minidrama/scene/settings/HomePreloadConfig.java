// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;

import java.util.Objects;

/** 首页代码配置；客户可按实验组设置，不依赖尚未实现的云端开关。
 * Home code configuration; assign per experiment group without assuming a cloud switch exists.
 */
public final class HomePreloadConfig {
    public enum EntrySource { DEMO_PER_DRAMA, FEED_ONLY }

    public static final float DEFAULT_MAX_SCROLL_SPEED_DP_PER_SECOND = 1000f;
    public static final long DEFAULT_UPDATE_INTERVAL_MS = 100L;

    public final EntrySource entrySource;
    public final boolean enhancedWindowEnabled;
    public final float maxScrollSpeedDpPerSecond;
    public final long updateIntervalMs;

    private HomePreloadConfig(Builder builder) {
        entrySource = builder.entrySource;
        enhancedWindowEnabled = builder.enhancedWindowEnabled;
        maxScrollSpeedDpPerSecond = builder.maxScrollSpeed;
        updateIntervalMs = builder.updateIntervalMs;
    }

    public static HomePreloadConfig defaults() { return new Builder().build(); }

    public static final class Builder {
        private EntrySource entrySource = EntrySource.DEMO_PER_DRAMA;
        private boolean enhancedWindowEnabled = false;
        private float maxScrollSpeed = DEFAULT_MAX_SCROLL_SPEED_DP_PER_SECOND;
        private long updateIntervalMs = DEFAULT_UPDATE_INTERVAL_MS;

        public Builder entrySource(EntrySource value) {
            entrySource = Objects.requireNonNull(value);
            return this;
        }
        // 默认仅静止后准备可见的前2项；客户主动开启后才使用9项速度滑动窗口。
        // Opt in to the nine-task sliding window; otherwise prepare two visible entries at idle.
        public Builder enhancedWindowEnabled(boolean value) {
            enhancedWindowEnabled = value;
            return this;
        }
        // 0 表示仅静止时新增；拖动和惯性滚动使用同一速度阈值。
        // Zero admits only idle lists; drag and fling share the same speed threshold.
        public Builder maxScrollSpeedDpPerSecond(float value) {
            if (Float.isNaN(value) || Float.isInfinite(value) || value < 0) {
                throw new IllegalArgumentException("Scroll speed must be finite and nonnegative");
            }
            maxScrollSpeed = value;
            return this;
        }
        public Builder updateIntervalMs(long value) {
            if (value <= 0) throw new IllegalArgumentException("Update interval must be positive");
            updateIntervalMs = value;
            return this;
        }
        public HomePreloadConfig build() { return new HomePreloadConfig(this); }
    }
}
