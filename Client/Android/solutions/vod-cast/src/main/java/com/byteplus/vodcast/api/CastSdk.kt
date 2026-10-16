// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

import android.content.Context
import androidx.lifecycle.LifecycleOwner

/**
 * SDK entry point (protocol-agnostic layer). Integrate with the following workflow:
 *
 * ```kotlin
 * // Application#onCreate (or before first casting)
 * CastSdk.register(applicationContext, CastOptions.default())
 *
 * // Fragment / Activity
 * CastSdk.addLifecycleObserver(this)
 * CastSdk.controller().addListener(myListener)
 * castButton.setOnClickListener {
 *     CastSdk.controller().discovery().refresh() // Force refresh
 * }
 * ```
 *
 * `register` is idempotent, multiple calls use the first registration.
 * Different protocol implementations register themselves via `CastSdk.installImpl(...)`
 * in their respective modules (ChromeCast impl uses ServiceLoader by default).
 *
 * Designed to support lifecycle-aware integration and a stable protocol-neutral API.
 */
object CastSdk {

    @Volatile
    private var registered: Boolean = false

    @Volatile
    private var available: Boolean = false

    @Volatile
    private var controllerImpl: ICastController? = null

    @Volatile
    private var optionsImpl: CastOptions = CastOptions.default()

    @Volatile
    private var localPlayerHookImpl: LocalPlayerHook? = null

    /**
     * Install protocol implementation. Called by protocol modules
     * (default [com.byteplus.vodcast.impl.chromecast]).
     * Last registration wins (shared across Fragments).
     */
    @JvmStatic
    fun installImpl(controller: ICastController) {
        controllerImpl = controller
    }

    /**
     * Install a local player hook. Injection can happen at any time;
     * PlaybackBridge behaves as a no-op when no hook is installed.
     */
    @JvmStatic
    fun installLocalPlayerHook(hook: LocalPlayerHook?) {
        localPlayerHookImpl = hook
    }

    /** Current injected LocalPlayerHook; returns null if not injected. */
    @JvmStatic
    fun localPlayerHook(): LocalPlayerHook? = localPlayerHookImpl

    /**
     * Register SDK. Idempotent.
     *
     * Casting depends on Google Play Services. On devices without (a usable version of)
     * Play Services, the ChromeCast implementation cannot be installed; in that case the
     * SDK stays registered-but-unavailable and all accessors degrade gracefully instead
     * of crashing. Use [isAvailable] to decide whether to expose any casting UI.
     */
    @JvmStatic
    @Synchronized
    fun register(context: Context, options: CastOptions = CastOptions.default()) {
        if (registered) return
        registered = true
        optionsImpl = options
        val app = context.applicationContext
        if (!isGooglePlayServicesUsable(app)) {
            // No Play Services -> Cast framework is unusable. Stay unavailable, no UI, no crash.
            available = false
            return
        }
        if (controllerImpl == null) {
            // Direct same-module bootstrap. The previous reflection-based approach broke under
            // R8 minification (the bootstrapper got renamed), leaving the impl uninstalled.
            available = runCatching {
                com.byteplus.vodcast.impl.chromecast.ChromecastBootstrapper.boot(app)
            }.isSuccess
        } else {
            available = true
        }
    }

    /**
     * Returns true only when Play Services is usable AND the ChromeCast implementation has
     * been installed. UI entry points should be hidden when this is false.
     */
    @JvmStatic
    fun isAvailable(): Boolean = available && controllerImpl != null

    private fun isGooglePlayServicesUsable(context: Context): Boolean = runCatching {
        com.google.android.gms.common.GoogleApiAvailability.getInstance()
            .isGooglePlayServicesAvailable(context) ==
            com.google.android.gms.common.ConnectionResult.SUCCESS
    }.getOrDefault(false)

    @JvmStatic
    fun isRegistered(): Boolean = registered

    /**
     * Get protocol-agnostic playback controller. Throws [IllegalStateException]
     * if implementation is not registered.
     *
     * Prefer [controllerOrNull] in UI code so a missing implementation (e.g. no Play
     * Services) does not crash the app.
     */
    @JvmStatic
    fun controller(): ICastController =
        controllerImpl ?: error("CastSdk impl not installed. " +
                "Make sure vod-cast impl module is in dependencies and CastSdk.register(...) is called.")

    /** Non-throwing controller accessor; returns null when casting is unavailable. */
    @JvmStatic
    fun controllerOrNull(): ICastController? = controllerImpl

    /** Shortcut: expose discovery. */
    @JvmStatic
    fun discovery(): IDiscovery = controller().discovery()

    /** Non-throwing discovery accessor; returns null when casting is unavailable. */
    @JvmStatic
    fun discoveryOrNull(): IDiscovery? = controllerImpl?.discovery()

    /**
     * Bind SDK with [LifecycleOwner]: triggers [IDiscovery.start] on STARTED,
     * auto-stops on STOPPED, cleans up listeners on DESTROYED.
     */
    @JvmStatic
    fun addLifecycleObserver(owner: LifecycleOwner) {
        owner.lifecycle.addObserver(
            com.byteplus.vodcast.core.lifecycle.CastLifecycleBinder(this)
        )
    }

    /** Internal use: current effective global configuration. */
    @JvmStatic
    fun options(): CastOptions = optionsImpl
}

/**
 * Global configuration options. `default()` provides zero-config entry point.
 */
data class CastOptions(
    /** Whether listener callbacks are dispatched on main thread. Default true. */
    val dispatchOnMain: Boolean = true,
    /** Progress callback interval in milliseconds. Default 500ms. */
    val progressIntervalMs: Long = 500L,
    /** Connection timeout in milliseconds. Default 10s. */
    val connectTimeoutMs: Long = 10_000L,
    /** Timeout for onSessionResumed after SUSPENDED, in milliseconds. Default 30s. */
    val suspendedTimeoutMs: Long = 30_000L,
    /** Whether to resume local playback on DISCONNECTED. Default true. */
    val resumeLocalOnDisconnect: Boolean = true,
    /** Auto retry count for MEDIA_LOAD_FAILED. Default 1. */
    val mediaLoadRetry: Int = 1,
    /** Window for reconnect attempt after network recovery, in milliseconds. Default 10s. */
    val networkRecoveryReconnectMs: Long = 10_000L,
) {
    companion object {
        @JvmStatic
        fun default(): CastOptions = CastOptions()
    }
}
