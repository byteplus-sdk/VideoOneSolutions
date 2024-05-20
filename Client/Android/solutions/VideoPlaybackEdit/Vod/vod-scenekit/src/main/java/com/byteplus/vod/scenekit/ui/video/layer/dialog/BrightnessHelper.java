// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.app.Activity;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.FloatRange;
import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.utils.UIUtils;

public class BrightnessHelper {

    public static float get(@NonNull Activity activity) {
        Window window = activity.getWindow();
        if (window == null) return UIUtils.getSystemBrightness(activity);

        WindowManager.LayoutParams params = window.getAttributes();
        if (params == null) return UIUtils.getSystemBrightness(activity);

        return params.screenBrightness == -1 ? UIUtils.getSystemBrightness(activity) : params.screenBrightness;
    }

    public static void set(@NonNull Activity activity, @FloatRange(from = 0.0, to = 1.0) float value) {
        Window window = activity.getWindow();
        if (window == null) return;

        WindowManager.LayoutParams params = window.getAttributes();
        if (params == null) return;

        params.screenBrightness = value;
        window.setAttributes(params);
    }
}
