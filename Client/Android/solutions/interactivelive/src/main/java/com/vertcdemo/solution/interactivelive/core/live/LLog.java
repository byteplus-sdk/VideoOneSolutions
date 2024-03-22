// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import android.util.Log;

public class LLog {
    private static final String TAG = "LiveCore";

    public static void d(String tag, String message) {
        Log.d(TAG, "[" + tag + "] " + message);
    }

    public static void d(String tag, String message, Throwable tr) {
        Log.d(TAG, "[" + tag + "] " + message, tr);
    }

    public static void e(String tag, String message) {
        Log.e(TAG, "[" + tag + "] " + message);
    }
}
