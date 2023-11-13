// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net;

public interface IRequestCallback<T> {

    void onSuccess(T data);

    default void onError(int errorCode, String message) {
    }
}
