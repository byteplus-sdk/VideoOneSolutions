// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.cache.CacheKeyFactory;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.source.TrackSelector;
import com.byteplus.playerkit.player.ve.VEPlayerInit;
import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;

import java.util.List;

public class VodSDK {

    @SuppressLint("StaticFieldLeak")
    private static Context sContext;

    public static Context context() {
        return sContext;
    }

    public static void init(Context context,
                            String appId,
                            String appName,
                            String appChannel,
                            String appVersion,
                            String appRegion,
                            String licenseUri) {
        sContext = context;

        L.ENABLE_LOG = true;

        VideoSettings.init(context);

        VEPlayerInit.AppInfo appInfo = new VEPlayerInit.AppInfo.Builder()
                .setAppId(appId)
                .setAppName(appName)
                .setAppRegion(appRegion)
                .setAppChannel(appChannel)
                .setAppVersion(appVersion)
                .setLicenseUri(licenseUri)
                .build();

        final int qualityRes = Quality.QUALITY_RES_720;

        final TrackSelector trackSelector = new TrackSelector() {
            @NonNull
            @Override
            public Track selectTrack(int type, int trackType, @NonNull List<Track> tracks, @NonNull MediaSource source) {
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

        VEPlayerInit.init(context, appInfo, CacheKeyFactory.DEFAULT, trackSelector);
    }
}
