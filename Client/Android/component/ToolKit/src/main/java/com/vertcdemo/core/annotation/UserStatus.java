// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.annotation;


import static com.vertcdemo.core.annotation.UserStatus.AUDIENCE_INTERACTING;
import static com.vertcdemo.core.annotation.UserStatus.AUDIENCE_INVITING;
import static com.vertcdemo.core.annotation.UserStatus.CO_HOSTING;
import static com.vertcdemo.core.annotation.UserStatus.HOST_INVITING;
import static com.vertcdemo.core.annotation.UserStatus.OTHER;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        OTHER,
        HOST_INVITING,
        CO_HOSTING,
        AUDIENCE_INVITING,
        AUDIENCE_INTERACTING
})
@Retention(RetentionPolicy.SOURCE)
public @interface UserStatus {
    int OTHER = 1;
    int HOST_INVITING = 2;
    int CO_HOSTING = 3;
    int AUDIENCE_INVITING = 4;
    int AUDIENCE_INTERACTING = 5;
}