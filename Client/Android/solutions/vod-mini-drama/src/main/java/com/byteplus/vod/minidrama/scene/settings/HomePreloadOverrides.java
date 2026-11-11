// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;

import android.content.SharedPreferences;

/** Settings 本地实验参数；默认关闭，关闭后恢复客户代码配置。 */
public final class HomePreloadOverrides {
    public static final int MAX_SPEED_DP_PER_SECOND = 10000;
    public static final int MIN_UPDATE_INTERVAL_MS = 25;
    public static final int MAX_UPDATE_INTERVAL_MS = 1000;

    public final boolean enabled;
    public final boolean downloads;
    public final boolean startupWarmup;
    public final int speedDpPerSecond;
    public final int updateIntervalMs;

    public HomePreloadOverrides(boolean enabled, boolean downloads, boolean startupWarmup,
                                int speedDpPerSecond, int updateIntervalMs) {
        if (speedDpPerSecond < 0 || speedDpPerSecond > MAX_SPEED_DP_PER_SECOND
                || updateIntervalMs < MIN_UPDATE_INTERVAL_MS
                || updateIntervalMs > MAX_UPDATE_INTERVAL_MS) {
            throw new IllegalArgumentException("Invalid Home preload parameters");
        }
        this.enabled = enabled;
        this.downloads = downloads;
        this.startupWarmup = startupWarmup;
        this.speedDpPerSecond = speedDpPerSecond;
        this.updateIntervalMs = updateIntervalMs;
    }

    public static HomePreloadOverrides defaults() {
        return new HomePreloadOverrides(false, true, true,
                (int) HomePreloadConfig.DEFAULT_MAX_SCROLL_SPEED_DP_PER_SECOND,
                (int) HomePreloadConfig.DEFAULT_UPDATE_INTERVAL_MS);
    }

    HomePreloadConfig applyTo(HomePreloadConfig code) {
        return new HomePreloadConfig.Builder()
                .entrySource(code.entrySource)
                .maxScrollSpeedDpPerSecond(speedDpPerSecond)
                .updateIntervalMs(updateIntervalMs)
                .build();
    }

    static HomePreloadOverrides read(SharedPreferences preferences) {
        HomePreloadOverrides defaults = defaults();
        try {
            // 迁移旧“仅停止”配置，保存时移除模式字段；其他旧模式统一按速度。
            // Preserve the old idle-only choice as speed zero; discard the mode on save.
            int speed = "IDLE_ONLY".equals(preferences.getString("admission", null))
                    ? 0 : preferences.getInt("speed", defaults.speedDpPerSecond);
            return new HomePreloadOverrides(preferences.getBoolean("override", defaults.enabled),
                    preferences.getBoolean("downloads", defaults.downloads),
                    preferences.getBoolean("warmup", defaults.startupWarmup),
                    speed,
                    preferences.getInt("interval", defaults.updateIntervalMs));
        } catch (IllegalArgumentException | ClassCastException ignored) {
            return defaults;
        }
    }

    void save(SharedPreferences preferences) {
        preferences.edit().putBoolean("override", enabled).putBoolean("downloads", downloads)
                .putBoolean("warmup", startupWarmup).remove("admission")
                .putInt("speed", speedDpPerSecond).putInt("interval", updateIntervalMs).apply();
    }
}
