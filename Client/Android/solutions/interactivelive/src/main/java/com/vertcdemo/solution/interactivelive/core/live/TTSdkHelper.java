// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import android.text.TextUtils;
import android.text.format.DateFormat;

import androidx.annotation.NonNull;

import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.ttlicense2.License;
import com.pandora.ttlicense2.LicenseManager;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.interactivelive.BuildConfig;

public class TTSdkHelper {
    private static boolean isInitialized = false;

    public static void initTTVodSdk() {
        if (isInitialized) {
            return;
        }

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_ID)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_APP_ID in gradle.properties!");
        }

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_LICENSE_URI)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_LICENSE_URI in gradle.properties!");
        }

        String appChannel;
        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_CHANNEL)) {
            appChannel = "PlayStore";
        } else {
            appChannel = BuildConfig.LIVE_TTSDK_APP_CHANNEL;
        }
        Env.init(new Config.Builder()
                .setApplicationContext(AppUtil.getApplicationContext())
                .setAppID(BuildConfig.LIVE_TTSDK_APP_ID)
                .setAppName(BuildConfig.LIVE_TTSDK_APP_NAME)
                .setAppVersion(BuildConfig.APP_VERSION_NAME)
                .setAppChannel(appChannel)
                .setLicenseUri(BuildConfig.LIVE_TTSDK_LICENSE_URI)
                .setLicenseCallback(new LogLicenseManagerCallback())
                .build());

        isInitialized = true;
    }
}

/**
 * Log LicenseManager callback
 */
class LogLicenseManagerCallback implements LicenseManager.Callback {
    private static final String TAG = "TTSdkHelper";

    @Override
    public void onLicenseLoadSuccess(@NonNull String licenseUri, @NonNull String licenseId) {
        LLog.d(TAG, "onLicenseLoadSuccess");
        printLicense(licenseId);
    }

    @Override
    public void onLicenseLoadError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {
        LLog.d(TAG, "onLicenseLoadError:'" + licenseUri + "', retryAble: " + retryAble, e);
    }

    @Override
    public void onLicenseLoadRetry(@NonNull String licenseUri) {
        LLog.d(TAG, "onLicenseLoadRetry:'" + licenseUri + "'");
    }

    @Override
    public void onLicenseUpdateSuccess(@NonNull String licenseUri, @NonNull String licenseId) {
        LLog.d(TAG, "onLicenseUpdateSuccess:'" + licenseUri + "', licenseId: '" + licenseId + "'");
        printLicense(licenseId);
    }

    @Override
    public void onLicenseUpdateError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {
        LLog.d(TAG, "onLicenseUpdateError:'" + licenseUri + "', retryAble: " + retryAble, e);
    }

    @Override
    public void onLicenseUpdateRetry(@NonNull String licenseUri) {
        LLog.d(TAG, "onLicenseUpdateRetry:'" + licenseUri + "'");
    }

    static void printLicense(String licenseId) {
        License license = LicenseManager.getInstance().getLicense(licenseId);
        if (license == null) {
            LLog.d(TAG, "Failed to getLicense()");
            return;
        }

        LLog.d(TAG, "License Info:");
        LLog.d(TAG, " id: '" + license.getId() + "'");
        LLog.d(TAG, " package: '" + license.getPackageName() + "'");
        LLog.d(TAG, " type: " + license.getType());
        LLog.d(TAG, " version: " + license.getVersion());

        final License.Module[] modules = license.getModules();
        if (modules != null) {
            LLog.d(TAG, " modules: ");
            for (License.Module module : modules) {
                LLog.d(TAG, "  + name: '" + module.getName() + "'"
                        + ", start: " + DateFormat.format("yyyy-MM-dd kk:mm:ss", module.getStartTime())
                        + ", expire: " + DateFormat.format("yyyy-MM-dd kk:mm:ss", module.getExpireTime()));
            }
        } else {
            LLog.d(TAG, " modules: none");
        }
    }
}