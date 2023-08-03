// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus;

import android.util.Log;

import org.greenrobot.eventbus.EventBus;

public class SolutionEventBus {
    private static final String TAG = "SolutionBus";

    private static final EventBus sInstance = EventBus.getDefault();

    public static void post(Object object) {
        Log.d(TAG, "event=" + object.getClass());
        sInstance.post(object);
    }

    public static void register(Object object) {
        sInstance.register(object);
    }

    public static void unregister(Object object) {
        sInstance.unregister(object);
    }
}
