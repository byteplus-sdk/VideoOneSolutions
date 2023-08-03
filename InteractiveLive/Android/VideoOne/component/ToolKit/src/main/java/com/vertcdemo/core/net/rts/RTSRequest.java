// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import androidx.annotation.Nullable;

import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.IRequestCallback;

public final class RTSRequest<T> implements IRTSCallback {
    @Nullable
    public final IRequestCallback<T> callback;

    public Class<T> resultClass;

    public RTSRequest(@Nullable IRequestCallback<T> callback, Class<T> resultClass) {
        this.callback = callback;
        this.resultClass = resultClass;
    }

    public void onSuccess(@Nullable String data) {
        if (data == null || callback == null) {
            return;
        }
        if (resultClass == null) {
            callback.onSuccess(null);
            return;
        }
        T result = GsonUtils.gson().fromJson(data, resultClass);
        callback.onSuccess(result);
    }

    public void onError(int errorCode, @Nullable String message) {
        if (callback != null) {
            callback.onError(errorCode, message);
        }
    }
}
