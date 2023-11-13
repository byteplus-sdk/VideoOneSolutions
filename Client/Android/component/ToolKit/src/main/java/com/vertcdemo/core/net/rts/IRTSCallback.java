// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import androidx.annotation.MainThread;
import androidx.annotation.Nullable;

@MainThread
public interface IRTSCallback {
    @MainThread
    void onSuccess(@Nullable String data);

    @MainThread
    void onError(int errorCode, @Nullable String message);
}
