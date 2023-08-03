// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.http;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        AppNetworkStatus.CONNECTED,
        AppNetworkStatus.DISCONNECTED
})
@Retention(RetentionPolicy.SOURCE)
public @interface AppNetworkStatus {
    int DISCONNECTED = 0;
    int CONNECTED = 1;
}
