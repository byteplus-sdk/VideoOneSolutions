// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.strategy;

import android.content.Context;
import android.util.DisplayMetrics;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.player.volcengine.VolcConfig;
import com.byteplus.playerkit.player.volcengine.VolcPlayerInit;
import com.byteplus.playerkit.player.volcengine.VolcQuality;
import com.byteplus.playerkit.player.volcengine.VolcQualityConfig;
import com.byteplus.playerkit.player.volcengine.VolcQualityStrategy;
import com.byteplus.playerkit.player.volcengine.VolcScene;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.Arrays;
import java.util.List;

public class VideoQuality {
    public static final int VIDEO_QUALITY_DEFAULT = Quality.QUALITY_RES_720;

    public static String qualityDesc(int qualityRes) {
        if (qualityRes == 0) {
            return "未选择";
        }
        Quality quality = VolcQuality.quality(qualityRes);
        if (quality != null) {
            return quality.getQualityDesc();
        }
        return "UnKnown";
    }

    public static final List<Integer> QUALITY_RES_ARRAY_USER_SELECTED = Arrays.asList(
            Quality.QUALITY_RES_DEFAULT,
            Quality.QUALITY_RES_360,
            Quality.QUALITY_RES_480,
            Quality.QUALITY_RES_540,
            Quality.QUALITY_RES_720,
            Quality.QUALITY_RES_1080
    );

    public static final List<Integer> QUALITY_RES_ARRAY_DEFAULT = Arrays.asList(
            Quality.QUALITY_RES_360,
            Quality.QUALITY_RES_480,
            Quality.QUALITY_RES_540,
            Quality.QUALITY_RES_720,
            Quality.QUALITY_RES_1080
    );

    public static int getUserSelectedQualityRes(MediaSource mediaSource) {
        VideoItem videoItem = VideoItem.get(mediaSource);
        if (videoItem != null) {
            return VideoQuality.getUserSelectedQualityRes(videoItem.getPlayScene());
        }
        return Quality.QUALITY_RES_DEFAULT;
    }

    public static int getUserSelectedQualityRes(int playScene) {
        return VIDEO_QUALITY_DEFAULT;
    }

    public static void setUserSelectedQualityRes(int playScene, @Quality.QualityRes int qualityRes) {

    }

    public static boolean isEnableStartupABR(MediaSource mediaSource) {
        return mediaSource != null &&
                (mediaSource.getSourceType() == MediaSource.SOURCE_TYPE_MODEL || mediaSource.getSourceType() == MediaSource.SOURCE_TYPE_ID) &&
                VolcQualityStrategy.isEnableStartupABR(VolcConfig.get(mediaSource));
    }

    @NonNull
    public static VolcQualityConfig sceneGearConfig(int volcScene) {
        final VolcQualityConfig config = new VolcQualityConfig();
        config.enableStartupABR = false;
        config.enableSupperResolutionDowngrade = false;
        switch (volcScene) {
            case VolcScene.SCENE_SHORT_VIDEO: {
                config.defaultQuality = VolcQuality.QUALITY_720P;
                config.wifiMaxQuality = VolcQuality.QUALITY_720P;
                config.mobileMaxQuality = VolcQuality.QUALITY_480P;

                final VolcQualityConfig.VolcDisplaySizeConfig displaySizeConfig = new VolcQualityConfig.VolcDisplaySizeConfig();
                config.displaySizeConfig = displaySizeConfig;

                final int screenWidth = getScreenWidth(VolcPlayerInit.getContext());
                final int screenHeight = getScreenHeight(VolcPlayerInit.getContext());

                displaySizeConfig.screenWidth = screenWidth;
                displaySizeConfig.screenHeight = screenHeight;
                displaySizeConfig.displayWidth = (int) (screenHeight / 16f * 9);
                displaySizeConfig.displayHeight = screenHeight;
                return config;
            }
            case VolcScene.SCENE_FULLSCREEN: {
                config.defaultQuality = VolcQuality.QUALITY_480P;
                config.wifiMaxQuality = VolcQuality.QUALITY_1080P;
                config.mobileMaxQuality = VolcQuality.QUALITY_720P;

                final VolcQualityConfig.VolcDisplaySizeConfig displaySizeConfig = new VolcQualityConfig.VolcDisplaySizeConfig();
                config.displaySizeConfig = displaySizeConfig;

                final int screenWidth = getScreenWidth(VolcPlayerInit.getContext());
                final int screenHeight = getScreenHeight(VolcPlayerInit.getContext());

                displaySizeConfig.screenWidth = screenWidth;
                displaySizeConfig.screenHeight = screenHeight;
                displaySizeConfig.displayWidth = Math.max(screenWidth, screenHeight);
                displaySizeConfig.displayHeight = (int) (Math.max(screenWidth, screenHeight) / 16f * 9);
                return config;
            }
            case VolcScene.SCENE_UNKNOWN:
            case VolcScene.SCENE_LONG_VIDEO:
            case VolcScene.SCENE_DETAIL_VIDEO:
            case VolcScene.SCENE_FEED_VIDEO:
            default: {
                config.defaultQuality = VolcQuality.QUALITY_480P;
                config.wifiMaxQuality = VolcQuality.QUALITY_540P;
                config.mobileMaxQuality = VolcQuality.QUALITY_360P;

                final VolcQualityConfig.VolcDisplaySizeConfig displaySizeConfig = new VolcQualityConfig.VolcDisplaySizeConfig();
                config.displaySizeConfig = displaySizeConfig;

                final int screenWidth = getScreenWidth(VolcPlayerInit.getContext());
                final int screenHeight = getScreenHeight(VolcPlayerInit.getContext());

                displaySizeConfig.screenWidth = screenWidth;
                displaySizeConfig.screenHeight = screenHeight;
                displaySizeConfig.displayWidth = Math.min(screenWidth, screenHeight);
                displaySizeConfig.displayHeight = (int) (Math.min(screenWidth, screenHeight) / 16f * 9);
                return config;
            }
        }
    }

    public static int getScreenWidth(Context context) {
        if (context == null) {
            return 0;
        }
        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        return (dm == null) ? 0 : dm.widthPixels;
    }

    public static int getScreenHeight(Context context) {
        if (context == null) {
            return 0;
        }
        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        return (dm == null) ? 0 : dm.heightPixels;
    }
}