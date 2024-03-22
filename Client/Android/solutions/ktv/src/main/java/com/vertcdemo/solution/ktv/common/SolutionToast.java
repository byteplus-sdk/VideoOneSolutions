// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.common;

import android.annotation.SuppressLint;
import android.widget.Toast;

import androidx.annotation.StringRes;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.solution.ktv.utils.ContextProvider;

@SuppressLint("SoonBlockedPrivateApi")
public class SolutionToast {
    private SolutionToast() {
    }

    public static void show(String message) {
        ContextProvider.get();
        show(message, Toast.LENGTH_SHORT);
    }

    public static void show(@StringRes int resId) {
        ContextProvider.get();
        show(resId, Toast.LENGTH_SHORT);
    }

    public static void show(String message, int duration) {
        AppExecutors.mainThread().execute(() -> CenteredToast.show(message, duration));
    }

    public static void show(int message, int duration) {
        AppExecutors.mainThread().execute(() -> CenteredToast.show(message, duration));
    }
}
