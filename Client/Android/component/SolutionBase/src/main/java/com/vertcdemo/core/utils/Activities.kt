// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.utils

import android.graphics.Color
import android.view.View
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity

object Activities {
    @JvmStatic
    fun transparentStatusBar(activity: AppCompatActivity) = activity.window?.run {
        clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        val visibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        decorView.systemUiVisibility = visibility
        statusBarColor = Color.TRANSPARENT
    }
}