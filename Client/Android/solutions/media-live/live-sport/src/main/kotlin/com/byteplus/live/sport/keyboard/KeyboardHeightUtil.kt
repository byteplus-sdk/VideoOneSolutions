// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.keyboard

import android.app.Activity
import android.os.Build
import android.view.View
import android.view.WindowInsets
import androidx.annotation.RequiresApi

/**
 * Internal helper used by [KeyboardHeightProvider] on Android 11+ (API 30,
 * [Build.VERSION_CODES.R]). Clients of this package should never need to
 * touch it — go through [KeyboardHeightProvider] instead.
 *
 * Installs an [View.OnApplyWindowInsetsListener] on the host activity's
 * decorView and emits the raw IME inset whenever it changes. The decorView
 * still receives IME insets even when the window is configured with
 * `windowSoftInputMode=adjustNothing`: that flag only suppresses the system
 * resize / pan, it does not block inset dispatch.
 *
 * This class only reports "is the IME visible + raw IME height". The math
 * for translating a target view to follow the IME lives in
 * [KeyboardHeightProvider] because it depends on where the target sits
 * on screen.
 */
@RequiresApi(Build.VERSION_CODES.R)
internal class KeyboardHeightUtil(activity: Activity) {

    fun interface OnKeyboardVisibilityListener {
        fun onChanged(isVisible: Boolean, height: Int)
    }

    private val decorView: View = activity.window.decorView
    private var listener: OnKeyboardVisibilityListener? = null
    private var lastVisible = false
    private var lastHeight = 0

    private val insetsListener = View.OnApplyWindowInsetsListener { v, insets ->
        val imeInsets = insets.getInsets(WindowInsets.Type.ime())
        val visible = insets.isVisible(WindowInsets.Type.ime())
        val height = imeInsets.bottom
        if (visible != lastVisible || height != lastHeight) {
            lastVisible = visible
            lastHeight = height
            listener?.onChanged(visible, height)
        }
        // Forward insets so other consumers (EdgeToEdge handling, etc.) keep working.
        v.onApplyWindowInsets(insets)
    }

    fun register(listener: OnKeyboardVisibilityListener) {
        this.listener = listener
        decorView.setOnApplyWindowInsetsListener(insetsListener)
        decorView.requestApplyInsets()
    }

    fun unregister() {
        listener = null
        decorView.setOnApplyWindowInsetsListener(null)
    }
}
