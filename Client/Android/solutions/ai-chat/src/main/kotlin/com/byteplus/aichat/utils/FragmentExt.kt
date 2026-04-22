package com.byteplus.aichat.utils

import androidx.fragment.app.Fragment
import androidx.core.view.WindowCompat

fun Fragment.lightStatusBar() {
    WindowCompat.getInsetsController(
        requireActivity().window, requireView()
    ).isAppearanceLightStatusBars = true
}

fun Fragment.darkStatusBar() {
    WindowCompat.getInsetsController(
        requireActivity().window, requireView()
    ).isAppearanceLightStatusBars = false
}
