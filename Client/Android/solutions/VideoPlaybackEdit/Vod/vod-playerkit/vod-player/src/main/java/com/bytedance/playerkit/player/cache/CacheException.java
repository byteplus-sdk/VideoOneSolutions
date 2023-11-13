// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.cache;

import java.io.IOException;


public class CacheException extends IOException {

    public final int code;

    public CacheException(int code, String message) {
        super("code:" + code + "; msg:" + message);
        this.code = code;
    }

    public CacheException(int code, String message, Throwable cause) {
        super("code:" + code + "; msg:" + message, cause);
        this.code = code;
    }
}
