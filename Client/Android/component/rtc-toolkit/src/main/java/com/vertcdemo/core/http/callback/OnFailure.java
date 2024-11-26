// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http.callback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;

public class OnFailure<T> implements Callback<T> {

    @NonNull
    private final Consumer<HttpException> consumer;

    private OnFailure(@NonNull Consumer<HttpException> consumer) {
        this.consumer = consumer;
    }

    @Override
    public void onResponse(@Nullable T response) {
        // ignore onResponse
    }

    @Override
    public void onFailure(HttpException t) {
        consumer.accept(t);
    }

    public static <T> Callback<T> of(@Nullable Consumer<HttpException> consumer) {
        if (consumer == null) {
            return OnNext.empty();
        }
        return new OnFailure<>(consumer);
    }
}
