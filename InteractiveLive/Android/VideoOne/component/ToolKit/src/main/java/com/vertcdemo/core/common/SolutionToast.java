// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.common;

import android.content.Context;
import android.widget.Toast;

import androidx.annotation.StringRes;

import com.vertcdemo.core.utils.AppUtil;

public class SolutionToast {
    public static void show(CharSequence message) {
        show(AppUtil.getApplicationContext(), message, Toast.LENGTH_SHORT);
    }

    public static void show(@StringRes int resId) {
        show(AppUtil.getApplicationContext(), resId, Toast.LENGTH_SHORT);
    }

    public static void show(Context context, CharSequence message, int duration) {
        AppExecutors.mainThread().execute(() -> {
            Toast.makeText(context.getApplicationContext(), message, duration).show();
        });
    }

    public static void show(Context context, @StringRes int message, int duration) {
        AppExecutors.mainThread().execute(() -> {
            Toast.makeText(context.getApplicationContext(), message, duration).show();
        });
    }
}
