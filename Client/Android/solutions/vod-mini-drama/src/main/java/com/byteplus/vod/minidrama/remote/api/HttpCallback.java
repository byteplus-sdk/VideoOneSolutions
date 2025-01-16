// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.api;

public interface HttpCallback<T> {
    void onSuccess(T t);

    void onError(Throwable t);
}
