// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.http;

import com.vertcdemo.core.net.HttpException;

public interface Callback<T> {
    void onResponse(T response);

    void onFailure(HttpException e);
}
