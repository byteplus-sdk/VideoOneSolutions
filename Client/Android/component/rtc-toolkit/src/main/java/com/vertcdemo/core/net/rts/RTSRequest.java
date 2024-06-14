// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import android.util.Log;

import androidx.annotation.Nullable;

import com.google.gson.JsonSyntaxException;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.IRequestCallback;

import java.lang.reflect.Type;

public final class RTSRequest<T> implements IRTSCallback {
    private static final String TAG = "RTSRequest";
    @Nullable
    public final IRequestCallback<T> callback;

    @Nullable
    public Type resultClass;

    public RTSRequest(@Nullable IRequestCallback<T> callback, Type resultClass) {
        this.callback = callback;
        this.resultClass = resultClass;
    }

    public RTSRequest(@Nullable IRequestCallback<T> callback, Class<T> resultClass) {
        this.callback = callback;
        this.resultClass = resultClass;
    }

    public void onSuccess(@Nullable String data) {
        if (callback == null) {
            return;
        }
        if (resultClass == null || resultClass == Void.class) {
            callback.onSuccess(null);
            return;
        }
        try {
            T result = GsonUtils.gson().fromJson(data, resultClass);
            callback.onSuccess(result);
        } catch (JsonSyntaxException e) {
            Log.d(TAG, "Parse Error: " + resultClass, e);
            onError(-1, "JsonSyntaxException");
        }
    }

    public void onError(int errorCode, @Nullable String message) {
        if (callback != null) {
            callback.onError(errorCode, message);
        }
    }
}
