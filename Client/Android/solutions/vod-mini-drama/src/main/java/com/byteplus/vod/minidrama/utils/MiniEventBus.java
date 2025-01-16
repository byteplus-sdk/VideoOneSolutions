// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import androidx.annotation.NonNull;

import com.vertcdemo.core.eventbus.SkipLogging;

import org.greenrobot.eventbus.EventBus;

public class MiniEventBus {
    private static final String TAG = "MiniEventBus";

    private static final EventBus bus = EventBus.builder()
            .build();

    public static void post(@NonNull Object event) {
        Class<?> type = event.getClass();
        if (!type.isAnnotationPresent(SkipLogging.class)) {
            L.d(TAG, "post event: " + type.getSimpleName());
        }
        bus.post(event);
    }

    public static void register(@NonNull Object subscriber) {
        bus.register(subscriber);
    }

    public static void unregister(@NonNull Object subscriber) {
        bus.unregister(subscriber);
    }
}
