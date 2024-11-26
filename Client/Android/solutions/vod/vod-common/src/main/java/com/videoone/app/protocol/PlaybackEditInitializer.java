// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.app.Application;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.byteplus.vodcommon.BuildConfig;
import com.byteplus.vodcommon.VodSDK;

@Keep
public class PlaybackEditInitializer implements IInitializer {
    private static final String TAG = "VideoPlaybackEdit";

    static boolean initialized = false;

    @Override
    public void initialize(@NonNull Application application) {
        Log.d(TAG, "PlaybackEditInitializer.initialize(Application) called");

        if (TextUtils.isEmpty(BuildConfig.VOD_APP_ID)) {
            throw new NeedConfigurationException("Please setup VOD_APP_ID in gradle.properties!");
        }
        if (TextUtils.isEmpty(BuildConfig.VOD_LICENSE_URI)) {
            throw new NeedConfigurationException("Please setup VOD_LICENSE_URI in gradle.properties!");
        }

        PackageInfo info;
        String appName;
        try {
            info = application.getPackageManager().getPackageInfo(application.getPackageName(), 0);
            appName = info.applicationInfo.loadLabel(application.getPackageManager()).toString();
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException(e);
        }

        String appChannel;
        if (TextUtils.isEmpty(BuildConfig.VOD_APP_CHANNEL)) {
            appChannel = "PlayStore";
        } else {
            appChannel = BuildConfig.VOD_APP_CHANNEL;
        }
        VodSDK.init(application,
                BuildConfig.VOD_APP_ID,
                appName,
                appChannel,
                info.versionName,
                "singapore",
                BuildConfig.VOD_LICENSE_URI);

        initialized = true;
    }
}
