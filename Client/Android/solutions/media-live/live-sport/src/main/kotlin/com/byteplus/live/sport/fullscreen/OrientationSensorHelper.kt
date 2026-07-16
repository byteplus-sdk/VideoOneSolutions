// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.content.Context
import android.os.SystemClock
import android.view.OrientationEventListener

/**
 * Device-orientation watcher built on [OrientationEventListener].
 *
 * It reports the *physical* device orientation regardless of the system
 * "auto-rotate" setting, so a player screen can auto-enter landscape (and flip
 * between the two landscape directions) even when the user has auto-rotate
 * turned off — the behaviour most video apps ship.
 *
 * Stability rules (avoid the over-sensitive flip-flopping seen in practice):
 *  - A new bucket must hold steady for [STABLE_WINDOW_MS] before it is emitted.
 *  - Consecutive emissions are spaced at least [MIN_EMIT_INTERVAL_MS] apart.
 *
 * Self-contained and reusable: feed it a [Context] and a callback, then
 * [enable] / [disable] following the Activity lifecycle.
 *
 * Usage:
 * ```
 * val helper = OrientationSensorHelper(context) { orientation ->
 *     // map to setRequestedOrientation(...)
 * }
 * // onResume / onPause
 * helper.enable(); helper.disable()
 * ```
 */
class OrientationSensorHelper(
    context: Context,
    private val onChanged: (DeviceOrientation) -> Unit,
) {

    /** Bucketed device orientation derived from the raw sensor angle. */
    enum class DeviceOrientation { PORTRAIT, LANDSCAPE_LEFT, LANDSCAPE_RIGHT }

    /** Last orientation actually emitted to the host. */
    private var emitted: DeviceOrientation? = null

    /** Candidate orientation currently being debounced, plus when it appeared. */
    private var pending: DeviceOrientation? = null
    private var pendingSinceMs: Long = 0L

    /** Timestamp of the last emission, for the min-interval guard. */
    private var lastEmitMs: Long = 0L

    private val listener = object : OrientationEventListener(context) {
        override fun onOrientationChanged(degree: Int) {
            val orientation = bucket(degree) ?: return
            handle(orientation)
        }
    }

    /** Start listening. No-op if the device has no orientation sensor. */
    fun enable() {
        if (listener.canDetectOrientation()) listener.enable()
    }

    /** Stop listening and reset the debounce state. */
    fun disable() {
        listener.disable()
        pending = null
        pendingSinceMs = 0L
    }

    /**
     * Debounce: an orientation must stay stable for [STABLE_WINDOW_MS] and
     * respect the [MIN_EMIT_INTERVAL_MS] spacing before it reaches the host.
     */
    private fun handle(orientation: DeviceOrientation) {
        if (orientation == emitted) {
            // Already the active orientation; cancel any pending change.
            pending = null
            return
        }
        val now = SystemClock.elapsedRealtime()
        if (orientation != pending) {
            // New candidate — start its stability timer.
            pending = orientation
            pendingSinceMs = now
            return
        }
        // Same candidate as before: check it has been stable long enough and the
        // min interval since the last emission has elapsed.
        if (now - pendingSinceMs < STABLE_WINDOW_MS) return
        if (now - lastEmitMs < MIN_EMIT_INTERVAL_MS) return

        emitted = orientation
        pending = null
        lastEmitMs = now
        onChanged(orientation)
    }

    /**
     * Map a raw 0..359 sensor angle to one of the buckets, with a dead zone
     * around each boundary so a diagonally-held device doesn't flicker. Returns
     * null inside a dead zone or when the angle is unknown.
     *
     * [OrientationEventListener] angle convention (device held upright = 0,
     * increasing clockwise):
     *  - ~0 / ~360 → PORTRAIT
     *  - ~90       → device rotated so its LEFT edge points up. Natural-grip
     *                landscape maps to SCREEN_ORIENTATION_LANDSCAPE, so this is
     *                [LANDSCAPE_RIGHT] here (see DeviceOrientation usage in the
     *                host). This is the corrected mapping — the previous build
     *                had 90/270 swapped, which flipped landscape upside-down.
     *  - ~270      → device rotated the other way → [LANDSCAPE_LEFT].
     */
    private fun bucket(degree: Int): DeviceOrientation? {
        if (degree == OrientationEventListener.ORIENTATION_UNKNOWN) return null
        return when (degree) {
            in (360 - PORTRAIT_RANGE)..359, in 0..PORTRAIT_RANGE -> DeviceOrientation.PORTRAIT
            in (90 - LANDSCAPE_RANGE)..(90 + LANDSCAPE_RANGE) -> DeviceOrientation.LANDSCAPE_RIGHT
            in (270 - LANDSCAPE_RANGE)..(270 + LANDSCAPE_RANGE) -> DeviceOrientation.LANDSCAPE_LEFT
            else -> null
        }
    }

    private companion object {
        /** A candidate orientation must hold this long before being emitted. */
        const val STABLE_WINDOW_MS = 500L

        /** Minimum spacing between two emissions to the host. */
        const val MIN_EMIT_INTERVAL_MS = 1000L

        /** Half-width of the dead zone around each boundary, in degrees. */
        const val DEAD_ZONE = 15

        /** Acceptance window half-widths for each bucket. */
        const val PORTRAIT_RANGE = 45 - DEAD_ZONE
        const val LANDSCAPE_RANGE = 45 - DEAD_ZONE
    }
}
