// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http.callback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;

public class OnResponse<T> implements Callback<T> {

    @NonNull
    private final Consumer<T> consumer;

    private OnResponse(@NonNull Consumer<T> consumer) {
        this.consumer = consumer;
    }

    @Override
    public void onResponse(@Nullable T response) {
        consumer.accept(response);
    }

    @Override
    public void onFailure(HttpException t) {
        // ignore onFailure
    }

    public static <T> Callback<T> of(@Nullable Consumer<T> consumer) {
        if (consumer == null) {
            return OnNext.empty();
        }
        return new OnResponse<>(consumer);
    }
}
