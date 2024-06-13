// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player;

public class PlayerException extends Exception {

    public static final int CODE_ERROR_ACTION = 1;
    public static final int CODE_SOURCE_LOAD_ERROR = 2;
    public static final int CODE_SOURCE_SET_ERROR = 3;

    private final int code;

    public PlayerException(int code, String message) {
        super("code:" + code + "; msg:" + message);
        this.code = code;
    }

    public PlayerException(int code, String message, Throwable cause) {
        super("code:" + code + "; msg:" + message, cause);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
