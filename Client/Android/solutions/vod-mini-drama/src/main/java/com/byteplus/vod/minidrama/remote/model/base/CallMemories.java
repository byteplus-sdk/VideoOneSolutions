// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.base;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

import retrofit2.Call;

public class CallMemories {

    private final List<Call<?>> mCalls = new ArrayList<>();

    private final ReentrantLock mLock = new ReentrantLock();

    protected <T> Call<T> remember(@NonNull Call<T> call) {
        mLock.lock();
        try {
            mCalls.add(call);
        } finally {
            mLock.unlock();
        }
        return call;
    }

    protected void forget(@NonNull Call<?> call) {
        mLock.lock();
        try {
            mCalls.remove(call);
        } finally {
            mLock.unlock();
        }
    }

    public void cancel() {
        mLock.lock();
        try {
            for (Call<?> call : mCalls) {
                call.cancel();
            }
            mCalls.clear();
        } finally {
            mLock.unlock();
        }
    }
}
