// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.volcengine;

import static com.ss.ttvideoengine.strategy.StrategyManager.VERSION_2;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.cache.CacheKeyFactory;
import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.SubtitleSelector;
import com.byteplus.playerkit.player.source.TrackSelector;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.L;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.common.env.config.VodConfig;
import com.pandora.vod.VodSDK;
import com.ss.ttvideoengine.DataLoaderHelper;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.strategy.StrategyManager;

import java.io.File;
import java.util.concurrent.atomic.AtomicBoolean;


public class VolcPlayerInit {

    private final static AtomicBoolean sInited = new AtomicBoolean(false);

    private static Context sContext;
    private static CacheKeyFactory sCacheKeyFactory;
    private static TrackSelector sTrackSelector;
    private static SubtitleSelector sSubtitleSelector;

    public static VolcConfigUpdater sConfigUpdater;

    public static VolcSourceRefreshStrategy.VolcUrlRefreshFetcher.Factory sUrlRefreshFetcherFactory;


    public static String getDeviceId() {
        return VolcPlayer.getDeviceId();
    }

    public static String getSDKVersion() {
        return Env.getVersion();
    }

    public static void init(final Context context, AppInfo appInfo) {
        init(context,
                appInfo,
                CacheKeyFactory.DEFAULT,
                TrackSelector.DEFAULT,
                new VolcSubtitleSelector(),
                VolcConfigUpdater.DEFAULT,
                null);
    }

    public static void init(@NonNull Context context,
                            @NonNull AppInfo appInfo,
                            @Nullable CacheKeyFactory cacheKeyFactory,
                            @Nullable TrackSelector trackSelector,
                            @Nullable SubtitleSelector subtitleSelector,
                            @Nullable VolcConfigUpdater configUpdater,
                            @Nullable VolcSourceRefreshStrategy.VolcUrlRefreshFetcher.Factory urlRefreshFetcherFactory) {

        if (sInited.getAndSet(true)) return;

        sContext = context.getApplicationContext();

        if (trackSelector != null) {
            sTrackSelector = trackSelector;
        } else {
            sTrackSelector = TrackSelector.DEFAULT;
        }
        if (cacheKeyFactory != null) {
            sCacheKeyFactory = cacheKeyFactory;
        } else {
            sCacheKeyFactory = CacheKeyFactory.DEFAULT;
        }
        if (subtitleSelector != null) {
            sSubtitleSelector = subtitleSelector;
        } else {
            sSubtitleSelector = new VolcSubtitleSelector();
        }
        if (configUpdater != null) {
            sConfigUpdater = configUpdater;
        } else {
            sConfigUpdater = VolcConfigUpdater.DEFAULT;
        }

        sUrlRefreshFetcherFactory = urlRefreshFetcherFactory;

        initVOD(context, appInfo);

        CacheLoader.Default.set(new VolcCacheLoader(context, new VolcCacheTask.Factory(context)));

        Player.Factory.Default.set(new VolcPlayerFactory(context));
    }

    public static Context getContext() {
        return sContext;
    }

    public static TrackSelector getTrackSelector() {
        return sTrackSelector;
    }

    public static SubtitleSelector getSubtitleSelector() {
        return sSubtitleSelector;
    }

    public static CacheKeyFactory getCacheKeyFactory() {
        return sCacheKeyFactory;
    }

    public static VolcConfigUpdater getConfigUpdater() {
        return sConfigUpdater;
    }

    public static File cacheDir(Context context) {
        return new File(context.getCacheDir(), "bytedance/playerkit/volcplayer/video_cache");
    }

    private static void initVOD(Context context, AppInfo appInfo) {
        if (L.ENABLE_LOG) {
            VodSDK.openAllVodLog();
        }

        StrategyManager.setVersion(VERSION_2);

        if (VolcConfigGlobal.ENABLE_HLS_CACHE_MODULE) {
            TTVideoEngine.setIntValue(DataLoaderHelper.DATALOADER_KEY_ENABLE_HLS_PROXY, 1);
        }
        if (VolcConfigGlobal.ENABLE_USE_ORIGINAL_URL) {
            TTVideoEngine.setIntValue(DataLoaderHelper.DATALOADER_KEY_ENABLE_USE_ORIGINAL_URL, 1);
        }
        if (VolcConfigGlobal.ENABLE_USE_BACKUP_URL) {
            TTVideoEngine.setIntValue(DataLoaderHelper.DATALOADER_KEY_INT_ALLOW_TRY_THE_LAST_URL, 1);
        }
        File videoCacheDir = cacheDir(context);
        if (!videoCacheDir.exists()) videoCacheDir.mkdirs();
        VodConfig.Builder vodBuilder = new VodConfig.Builder(context)
                .setCacheDirPath(videoCacheDir.getAbsolutePath())
                .setMaxCacheSize(300 * 1024 * 1024);

        if (VolcConfigGlobal.ENABLE_ECDN &&
                VolcExtensions.isIntegrate(VolcExtensions.PLAYER_EXTENSION_ECDN)) {
            L.d(VolcPlayerInit.class, "initVOD", "ecdn fileKeyRegularExpression", VolcConfig.ECDN_FILE_KEY_REGULAR_EXPRESSION);
            TTVideoEngine.setStringValue(DataLoaderHelper.DATALOADER_KEY_STRING_VDP_FILE_KEY_REGULAR_EXPRESSION, VolcConfig.ECDN_FILE_KEY_REGULAR_EXPRESSION);
            vodBuilder.setLoaderType(2);
        }

        Env.init(new Config.Builder()
                .setApplicationContext(context)
                .setAppID(appInfo.appId)
                .setAppName(appInfo.appName)
                // 合法版本号应大于、等于 2 个分隔符，如："1.3.2"
                .setAppVersion(appInfo.appVersion)
                .setAppChannel(appInfo.appChannel)
                // 将 license 文件拷贝到 app 的 assets 文件夹中，并设置 LicenseUri
                // 下面 LicenseUri 对应工程中 assets 路径为：assets/license/vod.lic
                .setLicenseUri(appInfo.licenseUri)
                // 可不设置，默认值见下表
                .setVodConfig(vodBuilder.build())
                .build());

        VolcEngineStrategy.init();
        VolcNetSpeedStrategy.init();
        VolcSuperResolutionStrategy.init();
        VolcQualityStrategy.init();
        VolcSourceRefreshStrategy.init(sUrlRefreshFetcherFactory);
    }


    public static class AppInfo {
        public final String appId;
        public final String appName;
        public final String appChannel;
        public final String appVersion;
        public final String licenseUri;

        private AppInfo(Builder builder) {
            this.appId = builder.appId;
            this.appName = builder.appName;
            this.appChannel = builder.appChannel;
            this.appVersion = builder.appVersion;
            this.licenseUri = builder.licenseUri;
        }

        public static class Builder {
            private String appId;
            private String appName;
            private String appChannel;
            private String appVersion;
            private String licenseUri;

            public Builder setAppId(@NonNull String appId) {
                Asserts.checkNotNull(appId, "appId shouldn't be null");
                this.appId = appId;
                return this;
            }

            public Builder setAppName(@NonNull String appName) {
                Asserts.checkNotNull(appName, "appName shouldn't be null");
                this.appName = appName;
                return this;
            }

            public Builder setAppChannel(@Nullable String appChannel) {
                this.appChannel = appChannel;
                return this;
            }

            public Builder setAppVersion(@NonNull String appVersion) {
                Asserts.checkNotNull(appVersion, "appVersion shouldn't be null");
                this.appVersion = appVersion;
                return this;
            }

            public Builder setLicenseUri(@NonNull String licenseUri) {
                Asserts.checkNotNull(licenseUri, "licenseUri shouldn't be null");
                this.licenseUri = licenseUri;
                return this;
            }

            public AppInfo build() {
                Asserts.checkNotNull(appId, "appId shouldn't be null");
                Asserts.checkNotNull(appName, "appName shouldn't be null");
                Asserts.checkNotNull(appVersion, "appVersion shouldn't be null");
                Asserts.checkNotNull(licenseUri, "licenseUri shouldn't be null");
                return new AppInfo(this);
            }
        }
    }
}
