// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.player

import android.text.format.DateFormat
import android.util.Log
import com.pandora.ttlicense2.LicenseManager

/**
 * Logs TTSDK license load/update results. Kept inside live-sport (instead of
 * reusing live-entrance's copy) so the module stays self-contained and copyable
 * by customers. Purely diagnostic — drives no business logic.
 */
internal class SportLicenseCallback : LicenseManager.Callback {

    override fun onLicenseLoadSuccess(licenseUri: String, licenseId: String) {
        Log.d(TAG, "onLicenseLoadSuccess: $licenseUri")
        printLicense(licenseId)
    }

    override fun onLicenseLoadError(licenseUri: String, e: Exception, retryAble: Boolean) {
        Log.e(TAG, "onLicenseLoadError: '$licenseUri', retryAble=$retryAble", e)
    }

    override fun onLicenseLoadRetry(licenseUri: String) {
        Log.d(TAG, "onLicenseLoadRetry: '$licenseUri'")
    }

    override fun onLicenseUpdateSuccess(licenseUri: String, licenseId: String) {
        Log.d(TAG, "onLicenseUpdateSuccess: '$licenseUri'")
        printLicense(licenseId)
    }

    override fun onLicenseUpdateError(licenseUri: String, e: Exception, retryAble: Boolean) {
        Log.e(TAG, "onLicenseUpdateError: '$licenseUri', retryAble=$retryAble", e)
    }

    override fun onLicenseUpdateRetry(licenseUri: String) {
        Log.d(TAG, "onLicenseUpdateRetry: '$licenseUri'")
    }

    private fun printLicense(licenseId: String) {
        val license = LicenseManager.getInstance().getLicense(licenseId)
        if (license == null) {
            Log.d(TAG, "Failed to getLicense()")
            return
        }
        Log.d(TAG, "License id='${license.id}' package='${license.packageName}' type=${license.type} version=${license.version}")
        license.modules?.forEach { module ->
            Log.d(
                TAG,
                "  + ${module.name} start=${DateFormat.format("yyyy-MM-dd kk:mm:ss", module.startTime)} " +
                    "expire=${DateFormat.format("yyyy-MM-dd kk:mm:ss", module.expireTime)}",
            )
        }
    }

    companion object {
        private const val TAG = "SportLicense"
    }
}
