// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.util;

import android.content.Context;

import com.vertcdemo.core.utils.AppUtil;

public class LiveCoreConfig {

    private static final String PREFS_NAME = "live_core_config";

    private static final String KEY_RTM_PULL_STREAMING = "rtm_pull_streaming";
    private static final String KEY_ABR = "abr";

    public static void setRtmPullStreaming(boolean value) {
        Context context = AppUtil.getApplicationContext();
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_RTM_PULL_STREAMING, value)
                .apply();
    }

    public static boolean getRtmPullStreaming() {
        Context context = AppUtil.getApplicationContext();
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_RTM_PULL_STREAMING, false);
    }

    public static void setABR(boolean value) {
        Context context = AppUtil.getApplicationContext();
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_ABR, value)
                .apply();
    }

    public static boolean getABR() {
        Context context = AppUtil.getApplicationContext();
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_ABR, false);
    }
}
