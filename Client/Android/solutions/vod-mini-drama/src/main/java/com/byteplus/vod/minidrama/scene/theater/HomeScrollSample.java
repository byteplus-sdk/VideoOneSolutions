// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.scene.settings.HomePreloadConfig;

/** 按实际消耗的滚动距离采样，首帧和过期样本不作为低速。
 * Sample consumed scroll distance; neither the first frame nor a stale sample means low speed.
 */
final class HomeScrollSample {
    static final long MAX_SAMPLE_GAP_MS = 200L;
    private static final float MILLIS_PER_SECOND = 1000f;
    private boolean scrolling;
    private long lastTimeMs = -1;
    private float speed = Float.NaN;
    private int direction = 1;

    void stateChanged(int newState) {
        boolean moving = newState != RecyclerView.SCROLL_STATE_IDLE;
        // Drag 转 Fling 保留采样，只在开始/停止滚动时重置。
        // Preserve samples across drag/fling transitions; reset when motion starts or stops.
        if (scrolling == moving) return;
        scrolling = moving;
        lastTimeMs = -1;
        speed = Float.NaN;
    }

    void scrolled(int dx, int dy, float density, long nowMs) {
        if (dx == 0 && dy == 0) return; // 布局通知不是速度样本。 Layout is not a speed sample.
        direction = (Math.abs(dy) >= Math.abs(dx) ? dy : dx) < 0 ? -1 : 1;
        long deltaMs = lastTimeMs < 0 ? 0 : nowMs - lastTimeMs;
        if (deltaMs <= 0 || deltaMs > MAX_SAMPLE_GAP_MS) {
            speed = Float.NaN;
        } else {
            speed = (float) Math.hypot(dx, dy) / density * MILLIS_PER_SECOND / deltaMs;
        }
        lastTimeMs = nowMs;
    }

    boolean allowsStart(HomePreloadConfig config, long nowMs) {
        if (!scrolling) return true;
        return config.maxScrollSpeedDpPerSecond > 0 && hasRecentSpeed(nowMs)
                && speed <= config.maxScrollSpeedDpPerSecond;
    }

    private boolean hasRecentSpeed(long nowMs) {
        return !Float.isNaN(speed) && nowMs >= lastTimeMs
                && nowMs - lastTimeMs <= MAX_SAMPLE_GAP_MS;
    }

    int direction() { return direction; }
}
