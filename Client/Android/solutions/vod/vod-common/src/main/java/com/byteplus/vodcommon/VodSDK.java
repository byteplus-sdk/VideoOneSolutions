// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.cache.CacheKeyFactory;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.source.TrackSelector;
import com.byteplus.playerkit.player.volcengine.VolcConfig;
import com.byteplus.playerkit.player.volcengine.VolcConfigGlobal;
import com.byteplus.playerkit.player.volcengine.VolcConfigUpdater;
import com.byteplus.playerkit.player.volcengine.VolcPlayerInit;
import com.byteplus.playerkit.player.volcengine.VolcQuality;
import com.byteplus.playerkit.player.volcengine.VolcSubtitleSelector;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.strategy.VideoQuality;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class VodSDK {


    @SuppressLint("StaticFieldLeak")
    private static Context sContext;
    private static final AtomicBoolean sInited = new AtomicBoolean();

    public static Context context() {
        return sContext;
    }

    public static void init(Context context,
                            String appId,
                            String appName,
                            String appChannel,
                            String appVersion,
                            String licenseUri) {

        if (sInited.getAndSet(true)) return;

        sContext = context;

        L.ENABLE_LOG = true;
        Asserts.DEBUG = BuildConfig.DEBUG;

        VideoSettings.init(context);

        VolcPlayerInit.AppInfo appInfo = new VolcPlayerInit.AppInfo.Builder()
                .setAppId(appId)
                .setAppName(appName)
                .setAppChannel(appChannel)
                .setAppVersion(appVersion)
                .setLicenseUri(licenseUri)
                .build();
        final TrackSelector trackSelector = new TrackSelector() {
            @NonNull
            @Override
            public Track selectTrack(int type, int trackType, @NonNull List<Track> tracks, @NonNull MediaSource source) {
                int qualityRes = VideoQuality.getUserSelectedQualityRes(source);
                if (qualityRes <= 0) {
                    qualityRes = VideoQuality.VIDEO_QUALITY_DEFAULT;
                }
                for (Track track : tracks) {
                    Quality quality = track.getQuality();
                    if (quality != null) {
                        if (quality.getQualityRes() == qualityRes) {
                            return track;
                        }
                    }
                }
                return tracks.get(0);
            }
        };

        final VolcConfigUpdater configUpdater = new VolcConfigUpdater() {
            @Override
            public void updateVolcConfig(MediaSource mediaSource) {
                VolcConfig config = VolcConfig.get(mediaSource);
                if (config.qualityConfig == null) return;
                if (!config.qualityConfig.enableStartupABR) return;

                final int qualityRes = VideoQuality.getUserSelectedQualityRes(mediaSource);
                if (qualityRes <= 0) {
                    config.qualityConfig.userSelectedQuality = null;
                } else {
                    config.qualityConfig.userSelectedQuality = VolcQuality.quality(qualityRes);
                }
            }
        };

        // 不使用 ECDN 无需关心
        if (VolcConfigGlobal.ENABLE_ECDN) {
            VolcConfig.ECDN_FILE_KEY_REGULAR_EXPRESSION = "[a-zA-z]+://[^/]*/[^/]*/[^/]*/(.*?)\\?.*";
        }

//        // 播放源刷新策略
//        AppUrlRefreshFetcher.Factory urlRefresherFactory = null;
//        if (VideoSettings.booleanValue(VideoSettings.COMMON_ENABLE_SOURCE_403_REFRESH)) {
//            urlRefresherFactory = new AppUrlRefreshFetcher.Factory();
//        }

        VolcPlayerInit.init(context,
                appInfo,
                CacheKeyFactory.DEFAULT,
                trackSelector,
                new VolcSubtitleSelector(),
                configUpdater,
                null);
    }
}
