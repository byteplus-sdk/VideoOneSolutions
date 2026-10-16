// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.view.View
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat

/**
 * Immersive fullscreen helper for landscape video playback.
 *
 * Self-contained and Activity-agnostic so it can be copied into any player
 * screen: it only touches the window's insets controller and the
 * decor-fits-system-windows flag, restoring both on [exit].
 *
 * Usage:
 * ```
 * // entering landscape
 * FullscreenUtil.enter(activity)
 * // leaving landscape
 * FullscreenUtil.exit(activity)
 * ```
 */
object FullscreenUtil {

    /**
     * Hide the status + navigation bars and let the content draw edge-to-edge.
     * Bars reappear transiently on a swipe from the edge (BEHAVIOR_SHOW_...).
     *
     * Uses ONLY the AndroidX insets controller. The legacy
     * [View.setSystemUiVisibility] immersive-sticky flags were removed: holding
     * both at once makes the two mechanisms disagree about bar visibility after
     * the IME perturbs the system UI, which manifests as the status bar flashing
     * on/off on its own. minSdk 24 supports the controller everywhere.
     */
    fun enter(activity: Activity) {
        val window = activity.window
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    /**
     * Restore the system bars. Pass the original decor-fits flag the screen
     * uses in portrait — this codebase runs portrait edge-to-edge
     * ([enableEdgeToEdge]), so the default keeps content edge-to-edge but makes
     * the bars visible again.
     */
    fun exit(activity: Activity, decorFitsSystemWindows: Boolean = false) {
        val window = activity.window
        WindowCompat.setDecorFitsSystemWindows(window, decorFitsSystemWindows)
        WindowInsetsControllerCompat(window, window.decorView)
            .show(WindowInsetsCompat.Type.systemBars())
    }

    /** The Activity's top-level DecorView, used to host the landscape overlay. */
    fun decorView(activity: Activity): View = activity.window.decorView
}
