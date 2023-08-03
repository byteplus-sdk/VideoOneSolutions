// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils;

import android.app.Application;

public class AppUtil {

    private static Application mAppCxt;

    public static void initApp(Application app) {
        mAppCxt = app;
    }

    public static Application getApplicationContext() {
        if (mAppCxt == null) {
            throw new IllegalStateException("Please init app at first!");
        } else {
            return mAppCxt;
        }
    }
}
