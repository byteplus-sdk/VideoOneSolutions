// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net;

import androidx.annotation.NonNull;


public class RequestCallbackAdapter<T> implements IRequestCallback<T> {

    private final Runnable mNext;

    public RequestCallbackAdapter(Runnable next) {
        mNext = next;
    }

    @Override
    public void onSuccess(T data) {
        if (mNext != null) mNext.run();
    }

    @Override
    public void onError(int errorCode, String message) {
        if (mNext != null) mNext.run();
    }


    public static <T> RequestCallbackAdapter<T> create(@NonNull Runnable next) {
        return new RequestCallbackAdapter<>(next);
    }
}
