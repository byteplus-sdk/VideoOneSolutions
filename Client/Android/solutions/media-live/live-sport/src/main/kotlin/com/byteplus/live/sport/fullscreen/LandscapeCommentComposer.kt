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
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.TextView
import com.byteplus.live.sport.R

/**
 * Full-width landscape comment composer shown above the soft keyboard.
 *
 * Window model:
 *  - The dialog uses a FULL-SCREEN transparent window with
 *    [SOFT_INPUT_ADJUST_RESIZE]. adjustResize only shrinks the visible window
 *    frame when the content view fills the window, so a full-screen root is
 *    required — a WRAP_CONTENT bottom window would NOT ride up with the IME.
 *  - The composer row is bottom-gravity inside that root, so as the window
 *    shrinks for the keyboard the row sits right on top of it.
 *  - A transparent scrim fills the rest; tapping it dismisses.
 *
 * The host Activity keeps its `adjustNothing` softInputMode — only this
 * dialog's own window resizes.
 *
 * Dismiss also fires when the keyboard is collapsed (e.g. Back press) so the
 * composer never lingers without the IME.
 *
 * Text is seeded from the small inline input ([initialText]) and reported back
 * via [onTextChanged] on dismiss so the two stay in sync. Send (button or IME
 * action) reports the message via [onSend].
 */
class LandscapeCommentComposer(
    private val activity: Activity,
    private val initialText: String,
    private val onSend: (String) -> Unit,
    private val onTextChanged: (String) -> Unit,
) {
    private val dialog = Dialog(activity, android.R.style.Theme_Translucent_NoTitleBar)
    private lateinit var input: EditText
    private lateinit var root: View
    private var keyboardWasOpen = false
    private var maxRootHeight = 0
    private var layoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

    fun show() {
        val container = FrameLayout(activity)

        val composer = LayoutInflater.from(activity)
            .inflate(R.layout.live_sport_landscape_composer, container, false)
        (composer.layoutParams as FrameLayout.LayoutParams).gravity = Gravity.BOTTOM
        container.addView(composer)
        // Tap outside the composer row → dismiss.
        container.setOnClickListener { dialog.dismiss() }
        composer.isClickable = true

        dialog.setContentView(
            container,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        root = container

        input = composer.findViewById(R.id.composer_input)
        val sendBtn = composer.findViewById<TextView>(R.id.composer_send)

        input.setText(initialText)
        input.setSelection(input.text?.length ?: 0)
        // NO_EXTRACT_UI stops the fullscreen IME in landscape, which would
        // otherwise cover the whole screen and break adjustResize (composer
        // wouldn't ride up, and keyboard-close wouldn't be detectable).
        input.imeOptions = EditorInfo.IME_ACTION_SEND or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        input.setOnEditorActionListener { _, actionId, _ ->
            if (actionId != EditorInfo.IME_ACTION_SEND) return@setOnEditorActionListener false
            commitSend()
            true
        }
        sendBtn.setOnClickListener { commitSend() }

        val window = dialog.window ?: return
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        window.setLayout(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
        )
        // Full-screen window + adjustResize so the bottom composer rides on top
        // of the keyboard. ALWAYS_VISIBLE forces the IME up as soon as the
        // window gains focus. Activity softInputMode is untouched.
        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
                WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE,
        )
        // The keyboard / composer is allowed to show the status bar normally
        // (no immersive juggling here — that caused the bar to jump). We only
        // restore the Activity's immersive fullscreen on dismiss, once the IME
        // is gone, so the status bar disappears again afterwards.
        //
        // We deliberately do NOT call setDecorFitsSystemWindows(false) — that
        // switches the window to edge-to-edge so the IME inset no longer shrinks
        // the window frame, which would break the adjustResize-based keyboard
        // detection below and stop the composer row from riding up. The host
        // Activity softInputMode stays untouched.

        observeKeyboard()
        dialog.setOnDismissListener {
            layoutListener?.let { root.viewTreeObserver.removeOnGlobalLayoutListener(it) }
            onTextChanged(input.text?.toString().orEmpty())
            // The IME interaction re-showed the Activity's status bar; re-hide it
            // by reapplying the landscape immersive fullscreen on the Activity.
            //
            // We hide twice: once now, and once after a short delay. The IME's
            // closing animation emits a TRANSIENT status-bar show that lands a
            // few frames AFTER this dismiss, overriding an immediate-only hide
            // (the bar then lingers for the system's transient timeout). The
            // delayed second pass runs after that transient arrives and hides it
            // for good.
            FullscreenUtil.enter(activity)
            activity.window.decorView.postDelayed(
                { FullscreenUtil.enter(activity) },
                REHIDE_DELAY_MS,
            )
        }

        dialog.show()
        input.requestFocus()
        // Post-delayed so the dialog window has gained focus before we ask the
        // IME to show; without the delay showSoftInput is frequently dropped
        // and the keyboard only appears on a second tap.
        input.postDelayed({
            val imm = activity.getSystemService(Activity.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
        }, 100L)
    }

    /**
     * Dismiss when the keyboard closes (IME hide button / Back press) so the
     * composer doesn't linger without the keyboard.
     *
     * Under adjustResize the full-screen root is *shrunk* while the keyboard is
     * up and restored when it closes. So we track the tallest height we've seen
     * (= no keyboard) and compare: a meaningful shrink means the keyboard is
     * open, a restore to near-max after that means it closed.
     *
     * (WindowInsets.ime() can't be used here — adjustResize consumes the IME
     * inset so the listener never fires; a raw visible-frame delta also reads
     * ~0 because the resized root no longer spans the keyboard.)
     */
    private fun observeKeyboard() {
        val listener = ViewTreeObserver.OnGlobalLayoutListener {
            val h = root.height
            if (h <= 0) return@OnGlobalLayoutListener
            if (h > maxRootHeight) maxRootHeight = h
            val threshold = 100 * activity.resources.displayMetrics.density
            val shrunk = h < maxRootHeight - threshold
            if (shrunk) {
                keyboardWasOpen = true
            } else if (keyboardWasOpen) {
                dialog.dismiss()
            }
        }
        layoutListener = listener
        root.viewTreeObserver.addOnGlobalLayoutListener(listener)
    }

    private fun commitSend() {
        val text = input.text?.toString()?.trim().orEmpty()
        if (text.isEmpty()) return
        onSend(text)
        input.setText("")
        dialog.dismiss()
    }

    private companion object {
        /** Delay before the second immersive re-hide, to outlast the IME's
         *  closing transient status-bar show. */
        const val REHIDE_DELAY_MS = 300L
    }
}
