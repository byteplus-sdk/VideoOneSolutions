// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Looper;
import androidx.annotation.MainThread;
import com.byteplus.playerkit.player.playback.AdsPlaybackController;
import java.util.ArrayList;
import java.util.List;

public class DramaSettings {
    private static boolean ads = false;
    private static volatile boolean theaterEntryPreload = true;
    private static boolean theaterStartupWarmup = true;
    private static boolean theaterResumePointPreload = true;
    private static volatile HomePreloadConfig homePreloadConfig = HomePreloadConfig.defaults();
    private static HomePreloadConfig codeHomePreloadConfig = homePreloadConfig;
    private static boolean codeEntryPreload = true;
    private static boolean codeStartupWarmup = true;
    private static SharedPreferences homePreferences;
    private static HomePreloadOverrides homeOverrides = HomePreloadOverrides.defaults();
    private static final List<Runnable> homeConfigListeners = new ArrayList<>();

    public static HomePreloadConfig getHomePreloadConfig() { return homePreloadConfig; }

    // 主线程设置后重建当前窗口；切换入口来源后刷新首页以重新请求协议。
    // Rebuild the window on the main thread; refresh Home after changing the entry source.
    @MainThread
    public static void setHomePreloadConfig(HomePreloadConfig config) {
        requireMainThread();
        if (config == null) throw new IllegalArgumentException("Home preload config is required");
        codeHomePreloadConfig = config;
        rebuildHomeConfig();
        notifyHomeConfigChanged();
    }

    @MainThread
    public static void initializeHomeSettings(Context context) {
        requireMainThread();
        if (homePreferences != null) return;
        homePreferences = context.getApplicationContext()
                .getSharedPreferences("drama_home_preload", Context.MODE_PRIVATE);
        homeOverrides = HomePreloadOverrides.read(homePreferences);
        rebuildHomeConfig();
    }

    public static HomePreloadOverrides getHomePreloadOverrides() { return homeOverrides; }

    @MainThread
    public static void setHomePreloadOverrides(HomePreloadOverrides overrides) {
        requireMainThread();
        if (homePreferences == null) throw new IllegalStateException("Initialize Home settings first");
        if (overrides == null) throw new IllegalArgumentException("Home overrides are required");
        homeOverrides = overrides;
        overrides.save(homePreferences);
        rebuildHomeConfig();
        notifyHomeConfigChanged();
    }

    private static void rebuildHomeConfig() {
        // 缓存有效配置；滚动路径不读 SharedPreferences，也不反复创建配置对象。
        // Cache the effective config; scrolling never reads preferences or allocates configs.
        homePreloadConfig = homeOverrides.enabled
                ? homeOverrides.applyTo(codeHomePreloadConfig) : codeHomePreloadConfig;
        theaterEntryPreload = homeOverrides.enabled ? homeOverrides.downloads : codeEntryPreload;
        theaterStartupWarmup = homeOverrides.enabled ? homeOverrides.startupWarmup : codeStartupWarmup;
    }

    @MainThread
    public static void addHomeConfigListener(Runnable listener) {
        requireMainThread();
        if (!homeConfigListeners.contains(listener)) homeConfigListeners.add(listener);
    }
    @MainThread
    public static void removeHomeConfigListener(Runnable listener) {
        requireMainThread();
        homeConfigListeners.remove(listener);
    }

    private static void notifyHomeConfigChanged() {
        // 配置和页面状态在主线程串行更新；快照允许监听者在回调中注销。
        // Serialize config and UI state on main; the snapshot permits removal in callbacks.
        for (Runnable listener : new ArrayList<>(homeConfigListeners)) listener.run();
    }

    private static void requireMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw new IllegalStateException("Home preload settings must be changed on the main thread");
        }
    }

    public static void enableAds(boolean enable) {
        ads = enable;
    }

    public static boolean isAdsEnabled() {
        return ads;
    }

    public static void enablePrerollAd(boolean enable) {
        AdsPlaybackController.enablePrerollAd(enable);
    }

    public static boolean isPrerollAdEnabled() {
        return AdsPlaybackController.isPrerollAdEnabled();
    }

    public static void enableMidrollAd(boolean enable) {
        AdsPlaybackController.enableMidrollAd(enable);
    }

    public static boolean isMidrollAdEnabled() {
        return AdsPlaybackController.isMidrollAdEnabled();
    }

    public static void enablePostrollAd(boolean enable) {
        AdsPlaybackController.enablePostrollAd(enable);
    }

    public static boolean isPostrollAdEnabled() {
        return AdsPlaybackController.isPostrollAdEnabled();
    }

    // 仅控制首页入口的数据预加载，详情页策略独立配置。
    // Controls home-entry data preloading; the detail-page strategy is configured separately.
    @MainThread
    public static void enableTheaterEntryPreload(boolean enable) {
        requireMainThread();
        codeEntryPreload = enable;
        rebuildHomeConfig();
        notifyHomeConfigChanged();
    }

    public static boolean isTheaterEntryPreloadEnabled() {
        return theaterEntryPreload;
    }

    // Demo 默认开启：每个播放进程最多一次；关闭只取消，不恢复已消耗的机会。
    // Enabled in the demo by default; disabling cancels without restoring a consumed attempt.
    @MainThread
    public static void enableTheaterStartupWarmup(boolean enable) {
        requireMainThread();
        codeStartupWarmup = enable;
        rebuildHomeConfig();
        notifyHomeConfigChanged();
    }

    public static boolean isTheaterStartupWarmupEnabled() {
        return theaterStartupWarmup;
    }

    // 仅控制预加载起点，不改变详情页实际续播位置。
    // Controls the preload offset only, without changing the detail player's resume position.
    public static void enableTheaterResumePointPreload(boolean enable) {
        theaterResumePointPreload = enable;
    }

    public static boolean isTheaterResumePointPreloadEnabled() {
        return theaterResumePointPreload;
    }
}
