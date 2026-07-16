// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.player

import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.byteplus.live.sport.BuildConfig
import com.pandora.common.env.Env
import com.pandora.common.env.config.Config
import com.pandora.common.env.config.LogConfig
import com.pandora.ttlicense2.LicenseManager
import com.vertcdemo.core.utils.LicenseChecker
import com.vertcdemo.core.utils.LicenseResult

/**
 * One-time TTSDK environment + license bootstrap for the sports-streaming scene.
 *
 * Why this exists:
 * VeLivePlayer pull streaming requires the TTSDK [Env] to be initialised and the
 * license to be loaded BEFORE any `play()`, otherwise playback fails with
 * `VeLivePlayerInvalidLicense` (-1). In this app the SDK is initialised lazily by
 * `MediaLiveViewModel` only when the media-live API-example entry is opened — so
 * entering the sports scene directly leaves the SDK uninitialised. This object
 * mirrors that init (pull-only; no pusher resource prep) and is idempotent.
 *
 * Call [ensureInitialized] early (e.g. on the directory page) so the license is
 * ready by the time the watch page starts pulling.
 */
object SportLiveEnv {

    private const val TAG = "SportLiveEnv"

    @Volatile
    private var initialized = false

    /**
     * Initialise TTSDK [Env] exactly once. Safe to call repeatedly; subsequent
     * calls are no-ops. Must run before the first [SportLivePlayer.play].
     */
    @Synchronized
    fun ensureInitialized(context: Context) {
        if (initialized) return

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_ID)) {
            throw IllegalStateException("Please setup LIVE_TTSDK_APP_ID in gradle.properties!")
        }
        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_LICENSE_URI)) {
            throw IllegalStateException("Please setup LIVE_TTSDK_LICENSE_URI in gradle.properties!")
        }

        val appContext = context.applicationContext
        Env.openDebugLog(true)
        Env.openAppLog(true)
        LicenseManager.turnOnLogcat(true)

        val logPath = appContext.getExternalFilesDir("TTSDK")?.absolutePath
        val logConfig = LogConfig.Builder(appContext)
            .setLogPath(logPath)
            .setLogLevel(LogConfig.LogLevel.Debug)
            .build()

        Env.init(
            Config.Builder()
                .setApplicationContext(appContext)
                .setAppID(BuildConfig.LIVE_TTSDK_APP_ID)
                .setAppName(BuildConfig.LIVE_TTSDK_APP_NAME)
                .setAppChannel(BuildConfig.LIVE_TTSDK_APP_CHANNEL)
                .setLicenseUri(BuildConfig.LIVE_TTSDK_LICENSE_URI)
                .setLicenseCallback(SportLicenseCallback())
                .setLogConfig(logConfig)
                .build()
        )
        initialized = true
        Log.i(TAG, "TTSDK initialized: version=${Env.getVersion()} appId=${Env.getAppID()}")
    }

    /**
     * Pre-validate the bundled license (package-name match) off the main thread.
     * This catches the common "wrong license / package mismatch" case early and
     * lets the UI show a hint; actual SDK auth still happens inside TTSDK.
     *
     * @return [LicenseResult.ok] when valid, otherwise a result carrying a
     *         localized message resource id.
     */
    fun checkLicense(context: Context): LicenseResult =
        LicenseChecker.check(context, BuildConfig.LIVE_TTSDK_LICENSE_URI)
}
