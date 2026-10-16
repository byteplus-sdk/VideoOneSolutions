// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;
import com.byteplus.playerkit.player.playback.AdsPlaybackController;

public class DramaSettings {
    private static boolean ads = false;
    private static boolean theaterEntryPreload = true;
    private static boolean theaterResumePointPreload = true;

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

    public static void enableTheaterEntryPreload(boolean enable) {
        theaterEntryPreload = enable;
    }

    public static boolean isTheaterEntryPreloadEnabled() {
        return theaterEntryPreload;
    }

    public static void enableTheaterResumePointPreload(boolean enable) {
        theaterResumePointPreload = enable;
    }

    public static boolean isTheaterResumePointPreloadEnabled() {
        return theaterResumePointPreload;
    }
}
