// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

@file:JvmName("HyperOS")

package com.vertcdemo.core.utils

import android.app.Activity
import android.os.Build
import android.view.WindowManager

/**
 * Fix EdgeToEdge on Xiaomi devices.
 */
@JvmName("fixNavigationBar")
fun Activity.fixNavigationBar() {
    if ("Xiaomi" == Build.MANUFACTURER && Build.VERSION.SDK_INT <= 35) {
        // Xiaomi will fixed at Android 16
        window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
    }
}