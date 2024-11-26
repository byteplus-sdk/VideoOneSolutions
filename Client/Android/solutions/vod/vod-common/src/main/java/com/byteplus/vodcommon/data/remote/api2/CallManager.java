// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;

class CallManager {
    private final List<Call<?>> mCalls = new ArrayList<>();

    protected <T> Call<T> remember(@NonNull Call<T> call) {
        synchronized (mCalls) {
            mCalls.add(call);
        }
        return call;
    }

    protected void forget(Call<?> call) {
        synchronized (mCalls) {
            mCalls.remove(call);
        }
    }

    protected void forget() {
        synchronized (mCalls) {
            for (Call<?> call : mCalls) {
                call.cancel();
            }
            mCalls.clear();
        }
    }
}
