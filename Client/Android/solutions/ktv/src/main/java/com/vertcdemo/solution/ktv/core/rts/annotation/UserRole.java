// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


@IntDef({UserRole.HOST, UserRole.AUDIENCE})
@Retention(RetentionPolicy.SOURCE)
public @interface UserRole {
    int HOST = 1;
    int AUDIENCE = 2;
}
