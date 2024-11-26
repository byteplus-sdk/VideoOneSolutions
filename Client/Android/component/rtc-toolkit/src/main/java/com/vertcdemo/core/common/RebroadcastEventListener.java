// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.common;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;

import com.vertcdemo.core.eventbus.SolutionEventBus;

import java.lang.reflect.Type;

public final class RebroadcastEventListener<T> implements Consumer<String> {

    private final Type mType;

    public RebroadcastEventListener(@NonNull Type type) {
        this.mType = type;
    }

    @Override
    public void accept(String data) {
        T result = GsonUtils.gson().fromJson(data, mType);
        SolutionEventBus.post(result);
    }

    public static <T> RebroadcastEventListener<T> of(@NonNull Type type) {
        return new RebroadcastEventListener<>(type);
    }

}
