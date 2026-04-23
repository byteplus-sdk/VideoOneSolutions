// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;
import com.byteplus.playerkit.player.playback.AdsPlaybackController;

public class DramaSettings {
    private static boolean ads = false;

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
}
