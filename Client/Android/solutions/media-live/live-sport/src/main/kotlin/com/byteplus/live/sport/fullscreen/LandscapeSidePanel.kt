// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.app.Dialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout

/**
 * Base class for landscape side-slide panels (settings / quality / multi-camera).
 *
 * Window model:
 *  - The dialog window is full-screen (MATCH_PARENT × MATCH_PARENT) and
 *    transparent. The panel content is added to a full-screen [FrameLayout]
 *    anchored to the right edge with a fixed [widthPx] width.
 *  - Tapping the empty area outside the panel dismisses it; taps on the panel
 *    itself are swallowed.
 *  - The slide-in / slide-out animation is driven manually via translationX on
 *    the content view (not window animations) so the transparent backdrop
 *    doesn't slide with it.
 *
 * Immersive model:
 *  - The window never takes focus ([FLAG_NOT_FOCUSABLE]) and mirrors the host
 *    Activity's system-UI visibility so status / nav bars stay hidden. Because
 *    the window covers the whole screen, touches inside it (including the empty
 *    backdrop) are still delivered to the dialog.
 *
 * Subclasses implement [onCreateContent] to inflate their panel view and
 * [onBind] to wire interactions on it.
 */
abstract class LandscapeSidePanel(
    protected val activity: Activity,
    /** Width of the panel in pixels. Height is always MATCH_PARENT. */
    private val widthPx: Int,
) {

    private val dialog: Dialog = Dialog(activity, android.R.style.Theme_Translucent_NoTitleBar_Fullscreen)

    private var content: View? = null
    private var dismissing = false

    private var onShowListener: (() -> Unit)? = null
    private var onDismissListener: (() -> Unit)? = null

    /** Called once when the panel is shown. */
    fun setOnShow(listener: () -> Unit): LandscapeSidePanel {
        onShowListener = listener
        return this
    }

    /** Called when the panel is dismissed (any reason). */
    fun setOnDismiss(listener: () -> Unit): LandscapeSidePanel {
        onDismissListener = listener
        return this
    }

    fun show() {
        val inflater = LayoutInflater.from(activity)
        val panel = onCreateContent(inflater)
        content = panel

        val root = FrameLayout(activity)
        root.addView(
            panel,
            FrameLayout.LayoutParams(
                widthPx,
                FrameLayout.LayoutParams.MATCH_PARENT,
                Gravity.END,
            ),
        )
        // Tap outside the panel → dismiss. The panel swallows its own taps.
        root.setOnClickListener { dismiss() }
        panel.isClickable = true

        dialog.setContentView(root)

        val window = dialog.window ?: return
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        window.attributes = window.attributes.apply {
            width = WindowManager.LayoutParams.MATCH_PARENT
            height = WindowManager.LayoutParams.MATCH_PARENT
            windowAnimations = 0
        }
        // Don't steal focus → host Activity keeps its immersive system-UI flags
        // so status / nav bars stay hidden behind the panel. The full-screen
        // window still receives touches (including the backdrop tap).
        window.setFlags(
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        )
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility = activity.window.decorView.systemUiVisibility

        dialog.setOnDismissListener { onDismissListener?.invoke() }

        onBind(panel)

        // Offset the panel off-screen BEFORE the first frame so it never flashes
        // at its final position. animate in once it's laid out.
        panel.translationX = widthPx.toFloat()
        panel.viewTreeObserver.addOnPreDrawListener(
            object : android.view.ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    panel.viewTreeObserver.removeOnPreDrawListener(this)
                    panel.animate().translationX(0f).setDuration(SLIDE_IN_MS).start()
                    return true
                }
            },
        )

        dialog.show()
        onShowListener?.invoke()
    }

    fun dismiss() {
        if (!dialog.isShowing || dismissing) return
        val panel = content
        if (panel == null) {
            dialog.dismiss()
            return
        }
        dismissing = true
        panel.animate()
            .translationX(widthPx.toFloat())
            .setDuration(SLIDE_OUT_MS)
            .withEndAction { if (dialog.isShowing) dialog.dismiss() }
            .start()
    }

    /** Inflate the panel's content view. Called once per [show]. */
    protected abstract fun onCreateContent(inflater: LayoutInflater): View

    /** Wire interactions on the inflated content view. */
    protected open fun onBind(content: View) = Unit

    private companion object {
        const val SLIDE_IN_MS = 220L
        const val SLIDE_OUT_MS = 200L
    }
}
