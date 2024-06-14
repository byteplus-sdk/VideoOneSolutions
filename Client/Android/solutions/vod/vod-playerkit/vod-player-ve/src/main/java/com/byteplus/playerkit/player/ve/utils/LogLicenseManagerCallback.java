// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.ve.utils;

import android.text.format.DateFormat;
import android.util.Log;

import androidx.annotation.NonNull;

import com.pandora.ttlicense2.License;
import com.pandora.ttlicense2.LicenseManager;

/**
 * Log LicenseManager callback
 */
public class LogLicenseManagerCallback implements LicenseManager.Callback {
    private static final String TAG = "VEPlayerInit";

    @Override
    public void onLicenseLoadSuccess(@NonNull String licenseUri, @NonNull String licenseId) {
        Log.d(TAG, "onLicenseLoadSuccess");
        printLicense(licenseId);
    }

    @Override
    public void onLicenseLoadError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {
        Log.d(TAG, "onLicenseLoadError:'" + licenseUri + "', retryAble: " + retryAble, e);
    }

    @Override
    public void onLicenseLoadRetry(@NonNull String licenseUri) {
        Log.d(TAG, "onLicenseLoadRetry:'" + licenseUri + "'");
    }

    @Override
    public void onLicenseUpdateSuccess(@NonNull String licenseUri, @NonNull String licenseId) {
        Log.d(TAG, "onLicenseUpdateSuccess:'" + licenseUri + "', licenseId: '" + licenseId + "'");
        printLicense(licenseId);
    }

    @Override
    public void onLicenseUpdateError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {
        Log.d(TAG, "onLicenseUpdateError:'" + licenseUri + "', retryAble: " + retryAble, e);
    }

    @Override
    public void onLicenseUpdateRetry(@NonNull String licenseUri) {
        Log.d(TAG, "onLicenseUpdateRetry:'" + licenseUri + "'");
    }

    static void printLicense(String licenseId) {
        License license = LicenseManager.getInstance().getLicense(licenseId);
        if (license == null) {
            Log.d(TAG, "Failed to getLicense()");
            return;
        }

        Log.d(TAG, "License Info:");
        Log.d(TAG, " id: '" + license.getId() + "'");
        Log.d(TAG, " package: '" + license.getPackageName() + "'");
        Log.d(TAG, " type: " + license.getType());
        Log.d(TAG, " version: " + license.getVersion());

        final License.Module[] modules = license.getModules();
        if (modules != null) {
            Log.d(TAG, " modules: ");
            for (License.Module module : modules) {
                Log.d(TAG, "  + name: '" + module.getName() + "'"
                        + ", start: " + DateFormat.format("yyyy-MM-dd kk:mm:ss", module.getStartTime())
                        + ", expire: " + DateFormat.format("yyyy-MM-dd kk:mm:ss", module.getExpireTime()));
            }
        } else {
            Log.d(TAG, " modules: none");
        }
    }
}
