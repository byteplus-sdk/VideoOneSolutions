// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.view.doOnLayout
import com.byteplus.live.sport.R

/**
 * Drives the landscape (fullscreen) experience WITHOUT recreating the Activity.
 *
 * Strategy (no setContentView swap, no layout-land):
 *  1. The portrait layout stays mounted underneath, untouched.
 *  2. On [enter] we inflate [R.layout.live_sport_watch_landscape] and attach it
 *     straight to the Activity's DecorView as a top overlay.
 *  3. The player's [TextureView] is *moved* from its portrait parent into the
 *     overlay's player container — same view, same SurfaceTexture — so playback
 *     never restarts. [exit] moves it back.
 *  4. The TextureView is sized to a 16:9 fitCenter box (letterboxed) inside the
 *     full-screen container.
 *
 * Visibility model (driven by user product spec):
 *  - Tapping the video toggles the controls (top/bottom bars + lock button).
 *  - When controls become visible they auto-hide after [AUTO_HIDE_MS]; any
 *    interaction or external [keepControlsVisible] call resets the timer.
 *  - Locked state: top/bottom bars stay hidden; tapping the video flashes ONLY
 *    the lock button for [AUTO_HIDE_MS] so the user can unlock.
 *
 * The controller owns only structure + show/hide/lock UI mechanics; the host
 * binds business logic (follow / pause / settings / camera / quality) onto the
 * views it exposes via [onBindControls]. This keeps the helper copy-pastable
 * across player screens.
 */
class LandscapeController(
    private val activity: Activity,
    /** Portrait parent the TextureView normally lives in (e.g. region_player). */
    private val portraitPlayerContainer: ViewGroup,
    private val playerTexture: TextureView,
) {

    /** True while the landscape overlay is attached. */
    var isShowing: Boolean = false
        private set

    /** True while the screen is locked (controls hidden, orientation pinned). */
    var isLocked: Boolean = false
        private set

    private var overlay: View? = null
    private var stage: View? = null
    private var controls: View? = null
    private var lockButton: View? = null
    private var playerContainer: FrameLayout? = null
    private var videoAspectWidth: Int = DEFAULT_VIDEO_W
    private var videoAspectHeight: Int = DEFAULT_VIDEO_H

    private val handler = Handler(Looper.getMainLooper())
    private val hideRunnable = Runnable { hideControls() }

    /**
     * When non-zero we keep the controls visible regardless of the auto-hide
     * timer. Used when the user is composing a comment, or a side panel is
     * open. Counted (not boolean) so multiple overlapping reasons don't fight.
     */
    private var persistentHoldCount: Int = 0

    private val decor: ViewGroup
        get() = activity.window.decorView as ViewGroup

    /**
     * Inflate + attach the overlay, move the TextureView into it and enter
     * immersive fullscreen.
     *
     * @param onBindControls invoked once with the inflated overlay root so the
     *        host can wire click listeners / set the lock toggle, etc.
     */
    fun enter(onBindControls: (root: View) -> Unit) {
        if (isShowing) return
        val root = LayoutInflater.from(activity)
            .inflate(R.layout.live_sport_watch_landscape, decor, false)
        overlay = root
        stage = root.findViewById(R.id.landscape_stage)
        controls = root.findViewById(R.id.landscape_controls)
        lockButton = root.findViewById(R.id.btn_landscape_lock)
        playerContainer = root.findViewById(R.id.landscape_player_container)

        decor.addView(
            root,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )

        // Size the centered stage to the largest 16:9 box; video + controls all
        // live inside it, so nothing spills onto the side letterbox bars.
        sizeStageToFit()
        moveTextureInto(playerContainer!!)
        FullscreenUtil.enter(activity)

        isShowing = true
        isLocked = false
        persistentHoldCount = 0
        onBindControls(root)
        // Start with controls visible + auto-hide armed.
        showControls()
    }

    fun updateVideoAspectRatio(width: Int, height: Int) {
        if (width <= 0 || height <= 0) return
        videoAspectWidth = width
        videoAspectHeight = height
        sizeStageToFit()
    }

    /** Detach the overlay, move the TextureView back and leave fullscreen. */
    fun exit() {
        if (!isShowing) return
        cancelHideTimer()
        // Restore the TextureView to the portrait container (full-bleed).
        moveTextureInto(portraitPlayerContainer)
        overlay?.let { decor.removeView(it) }
        FullscreenUtil.exit(activity)

        overlay = null
        stage = null
        controls = null
        lockButton = null
        playerContainer = null
        isShowing = false
        isLocked = false
        persistentHoldCount = 0
    }

    /**
     * Tap-on-video handler. Behaviour depends on the locked state:
     *  - non-locked: toggle the full controls (with auto-hide timer).
     *  - locked:     flash ONLY the lock button for [AUTO_HIDE_MS]; the rest of
     *                the controls stay hidden so the user's lock intent is
     *                respected.
     */
    fun onVideoTapped() {
        if (isLocked) {
            val lock = lockButton ?: return
            if (lock.visibility == View.VISIBLE) {
                lock.visibility = View.GONE
                cancelHideTimer()
            } else {
                lock.visibility = View.VISIBLE
                armHideTimer()
            }
            return
        }
        val c = controls ?: return
        if (c.visibility == View.VISIBLE) {
            hideControls()
        } else {
            showControls()
        }
    }

    /** Show the controls + lock button and arm the auto-hide timer. */
    fun showControls() {
        if (isLocked) return
        controls?.visibility = View.VISIBLE
        lockButton?.visibility = View.VISIBLE
        armHideTimer()
    }

    /** Hide the controls + lock button and cancel the timer. */
    fun hideControls() {
        if (isLocked) {
            // While locked the controls are already hidden; only the lock
            // button might be flashing — hide it too.
            lockButton?.visibility = View.GONE
        } else {
            controls?.visibility = View.GONE
            lockButton?.visibility = View.GONE
        }
        cancelHideTimer()
    }

    /**
     * Acquire / release a "keep visible" hold. While at least one hold is
     * active the auto-hide timer is suppressed and the controls stay shown.
     * Releasing the last hold re-arms the timer.
     *
     * Use cases: comment input has focus, a side panel is open.
     *
     * @param hold true to acquire, false to release. Calls must be balanced.
     */
    fun keepControlsVisible(hold: Boolean) {
        if (hold) {
            persistentHoldCount++
            // Make sure the controls are actually visible while held.
            if (!isLocked) {
                controls?.visibility = View.VISIBLE
                lockButton?.visibility = View.VISIBLE
            }
            cancelHideTimer()
        } else {
            if (persistentHoldCount > 0) persistentHoldCount--
            if (persistentHoldCount == 0) armHideTimer()
        }
    }

    /**
     * Toggle the locked state.
     *
     * Locking: hides every control (top/bottom bars + lock button) and any
     * caller is expected to also pin the orientation.
     * Unlocking: re-shows the controls and re-arms auto-hide.
     *
     * @return the new locked state.
     */
    fun toggleLock(): Boolean {
        isLocked = !isLocked
        if (isLocked) {
            controls?.visibility = View.GONE
            // Lock button is hidden too; tap-on-video will flash it back.
            lockButton?.visibility = View.GONE
            cancelHideTimer()
        } else {
            controls?.visibility = View.VISIBLE
            lockButton?.visibility = View.VISIBLE
            armHideTimer()
        }
        return isLocked
    }

    /** Re-arm the auto-hide timer unless something is holding controls open. */
    private fun armHideTimer() {
        cancelHideTimer()
        if (persistentHoldCount > 0) return
        handler.postDelayed(hideRunnable, AUTO_HIDE_MS)
    }

    private fun cancelHideTimer() {
        handler.removeCallbacks(hideRunnable)
    }

    /**
     * Move [playerTexture] into [target] as a full-bleed child. Both the
     * landscape stage and the portrait container are already shaped 16:9, so the
     * surface just fills its parent.
     */
    private fun moveTextureInto(target: ViewGroup) {
        (playerTexture.parent as? ViewGroup)?.removeView(playerTexture)
        playerTexture.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )
        target.addView(playerTexture, 0)
    }

    /**
     * Size [stage] to the largest centered 16:9 box that fits the screen, so the
     * video and every control inside it stay within 16:9 (no spill onto the side
     * letterbox bars). Recomputed on each decor layout pass to survive the
     * portrait→landscape size change and orientation flips.
     */
    private fun sizeStageToFit() {
        val s = stage ?: return
        val container = decor
        fun apply() {
            val w = container.width
            val h = container.height
            if (w <= 0 || h <= 0) return
            val targetW: Int
            val targetH: Int
            if (w * videoAspectHeight >= h * videoAspectWidth) {
                // Screen wider than 16:9 → height-bound, pillarbox left/right.
                targetH = h
                targetW = h * videoAspectWidth / videoAspectHeight
            } else {
                // Screen taller than 16:9 → width-bound, letterbox top/bottom.
                targetW = w
                targetH = w * videoAspectHeight / videoAspectWidth
            }
            val lp = s.layoutParams
            if (lp.width != targetW || lp.height != targetH) {
                lp.width = targetW
                lp.height = targetH
                s.layoutParams = lp
            }
        }
        container.addOnLayoutChangeListener { _, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom ->
            val changed = (right - left) != (oldRight - oldLeft) ||
                (bottom - top) != (oldBottom - oldTop)
            if (changed) apply()
        }
        container.doOnLayout { apply() }
    }

    private companion object {
        const val DEFAULT_VIDEO_W = 16
        const val DEFAULT_VIDEO_H = 9

        /** Auto-hide delay for the controls / lock-flash, per product spec. */
        const val AUTO_HIDE_MS = 5_000L
    }
}
