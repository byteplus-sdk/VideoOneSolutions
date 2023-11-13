// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.app.Application;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.Keep;

import com.bytedance.voddemo.VodSDK;
import com.bytedance.voddemo.impl.BuildConfig;

@Keep
public class PlaybackEditInitializer {
    private static final String TAG = "VideoPlaybackEdit";

    public void initialize(Application application) {
        Log.d(TAG, "PlaybackEditInitializer.initialize(Application) called");

        PackageInfo info;
        String appName;
        try {
            info = application.getPackageManager().getPackageInfo(application.getPackageName(), 0);
            appName = info.applicationInfo.loadLabel(application.getPackageManager()).toString();
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException(e);
        }
        VodSDK.init(application, BuildConfig.VOD_APP_ID, appName,
                BuildConfig.VOD_APP_CHANNEL, info.versionName,
                "singapore", BuildConfig.VOD_LICENSE_URI);
    }
}
