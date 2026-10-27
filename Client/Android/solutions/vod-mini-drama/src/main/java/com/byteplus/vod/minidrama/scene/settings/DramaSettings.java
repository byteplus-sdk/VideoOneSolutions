// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;
import com.byteplus.playerkit.player.playback.AdsPlaybackController;

public class DramaSettings {
    private static boolean ads = false;
    private static boolean theaterEntryPreload = true;
    private static boolean theaterResumePointPreload = true;
    private static boolean theaterEntryPreRender = true;

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
    public static void enableTheaterEntryPreload(boolean enable) {
        theaterEntryPreload = enable;
    }

    public static boolean isTheaterEntryPreloadEnabled() {
        return theaterEntryPreload;
    }

    // 默认仅预渲染首个候选以演示用法；实际候选由业务决定，建议同时只保留一个。
    // Prepare only the first candidate by default as a usage example. Let the app choose
    // the actual candidate, and keep at most one prepared player to limit memory usage.
    public static void enableTheaterEntryPreRender(boolean enable) {
        theaterEntryPreRender = enable;
    }

    public static boolean isTheaterEntryPreRenderEnabled() {
        return theaterEntryPreRender;
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
