// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.app.Application;
import android.util.Log;

import androidx.annotation.NonNull;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

/**
 * @see PlaybackEditInitializer
 */
public class InitializeManager {
    private static final String TAG = "InitializeManager";

    private static final List<String> INITIALIZERS = Arrays.asList(
            "com.videoone.app.protocol.PlaybackEditInitializer"
    );

    private static boolean called = false;

    public static void initialize(@NonNull Application application) {
        if (called) return;
        called = true;
        for (String initializer : INITIALIZERS) {
            invokeInitialize(application, initializer);
        }
    }

    private static void invokeInitialize(@NonNull Application application, @NonNull String className) {
        try {
            Class<?> clazz = Class.forName(className);
            Method method = clazz.getDeclaredMethod("initialize", Application.class);

            Object instance = clazz.newInstance();
            try {
                method.invoke(instance, application);
            } catch (ReflectiveOperationException e) {
                throw new IllegalStateException("call initialize() failed", e);
            }
        } catch (ReflectiveOperationException e) {
            Log.d(TAG, "invokeInitialize: failed", e);
        }
    }
}
