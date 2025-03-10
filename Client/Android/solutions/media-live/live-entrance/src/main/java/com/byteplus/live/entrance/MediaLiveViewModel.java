// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.entrance;

import static com.pandora.common.env.config.LogConfig.LogLevel.Debug;

import android.app.Application;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.byteplus.live.pusher.MediaResourceMgr;
import com.pandora.common.applog.AppLogWrapper;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.common.env.config.LogConfig;
import com.pandora.ttlicense2.LicenseManager;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.utils.LicenseChecker;
import com.vertcdemo.core.utils.LicenseResult;

import java.util.Objects;
import java.util.concurrent.atomic.AtomicBoolean;

public class MediaLiveViewModel extends AndroidViewModel {
    private static final String TAG = "MediaLiveViewModel";

    private final AtomicBoolean mIsResourceReady = new AtomicBoolean(false);

    public final MutableLiveData<LicenseResult> licenseResult = new MutableLiveData<>(LicenseResult.empty);

    public MediaLiveViewModel(@NonNull Application application) {
        super(application);
        prepareResource(application);
        initTTSDK(application);
    }

    public void checkLicense() {
        Context context = getApplication();
        AppExecutors.diskIO().execute(() -> {
            String licenseUri = BuildConfig.LIVE_TTSDK_LICENSE_URI;
            LicenseResult result = LicenseChecker.check(context, licenseUri);
            licenseResult.postValue(result);
        });
    }

    public boolean isResourceReady() {
        return mIsResourceReady.get();
    }

    private void prepareResource(Context context) {
        if (!mIsResourceReady.get()) {
            AppExecutors.diskIO().execute(() -> {
                MediaResourceMgr.prepare(context);
                mIsResourceReady.set(true);
            });
        }
    }

    private void initTTSDK(Application context) {
        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_ID)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_APP_ID in gradle.properties!");
        }

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_LICENSE_URI)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_LICENSE_URI in gradle.properties!");
        }

        Env.openDebugLog(true);
        Env.openAppLog(true);
        LicenseManager.turnOnLogcat(true);
        String logPath = Objects.requireNonNull(context.getExternalFilesDir("TTSDK")).getAbsolutePath();
        LogConfig config = new LogConfig.Builder(context)
                .setLogPath(logPath)
                .setLogLevel(Debug)
                .build();
        Env.init(new Config.Builder()
                .setApplicationContext(context)
                .setAppID(BuildConfig.LIVE_TTSDK_APP_ID)
                .setAppName(BuildConfig.LIVE_TTSDK_APP_NAME)
                .setAppChannel(BuildConfig.LIVE_TTSDK_APP_CHANNEL)
                .setLicenseUri(BuildConfig.LIVE_TTSDK_LICENSE_URI)
                .setLicenseCallback(new LogLicenseManagerCallback())
                .setLogConfig(config)
                .build());
        showBuildInfo();
    }

    private static void showBuildInfo() {
        Log.d(TAG, "[showBuildInfo] " + "TTSDK: " + Env.getVersion() +
                "\n  Flavor: " + Env.getFlavor() +
                "\n  BuildType: " + Env.getBuildType() +
                "\n  VersionCode: " + Env.getVersionCode() +
                "\n  AppID: " + Env.getAppID() +
                "\n  DeviceId: " + AppLogWrapper.getDid() +
                "\n  UUID: " + AppLogWrapper.getUserUniqueID() +
                "\n  License 2.0 is open");
    }
}
