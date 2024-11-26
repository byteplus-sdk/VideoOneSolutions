// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http.callback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;

public class OnNext<T> implements Callback<T> {
    private final Runnable consumer;

    private OnNext(@NonNull Runnable consumer) {
        this.consumer = consumer;
    }

    public void onResponse(@Nullable T response) {
        consumer.run();
    }

    @Override
    public void onFailure(HttpException t) {
        consumer.run();
    }

    public static <T> Callback<T> of(@Nullable Runnable consumer) {
        return consumer == null ? (Callback<T>) EMPTY : new OnNext<>(consumer);
    }

    private static final Callback<?> EMPTY = of(() -> {
    });

    public static <T> Callback<T> empty() {
        return (Callback<T>) EMPTY;
    }
}
