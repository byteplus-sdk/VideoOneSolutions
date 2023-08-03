// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net;

import androidx.annotation.Nullable;

public class ServerResponse<T> {
    private int code;
    private String msg;
    private T data;

    private ServerResponse(int code, String message, T data) {
        this.code = code;
        this.msg = message;
        this.data = data;
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }

    public T getData() {
        return data;
    }

    public static <T> ServerResponse<T> create(int code, String message, @Nullable T data) {
        return new ServerResponse<>(code, message, data);
    }
}

