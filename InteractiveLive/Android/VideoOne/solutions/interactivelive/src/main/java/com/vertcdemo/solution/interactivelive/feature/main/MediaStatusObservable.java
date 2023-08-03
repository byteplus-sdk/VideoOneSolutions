// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.core.util.Consumer;

import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;

import java.util.HashMap;
import java.util.Map;

/**
 * Manager Media Status
 */
@MainThread
public class MediaStatusObservable {
    private final Map<String, Consumer<UserMediaChangedEvent>> mCallbacks = new HashMap<>();


    public void onMediaChangedEvent(@NonNull UserMediaChangedEvent event) {
        final String userId = event.userId;
        final Consumer<UserMediaChangedEvent> consumer = mCallbacks.get(userId);
        if (consumer != null) {
            consumer.accept(event);
        }
    }

    protected void clearObservable() {
        mCallbacks.clear();
    }

    protected void putObservable(@NonNull String userId, @NonNull Consumer<UserMediaChangedEvent> consumer) {
        mCallbacks.put(userId, consumer);
    }
}
