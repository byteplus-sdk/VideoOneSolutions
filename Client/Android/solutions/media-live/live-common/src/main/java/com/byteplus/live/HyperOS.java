// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live;

import android.os.Build;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;

public class HyperOS {
    /**
     * Fix EdgeToEdge on Xiaomi devices.
     */
    public static void fixNavigationBar(AppCompatActivity activity) {
        if ("Xiaomi".equals(Build.MANUFACTURER)
                && Build.VERSION.SDK_INT <= 35) {
            // Xiaomi will fixed at Android 16
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        }
    }
}
