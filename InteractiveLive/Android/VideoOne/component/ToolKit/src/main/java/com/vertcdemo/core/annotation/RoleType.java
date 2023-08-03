// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.annotation;

import static com.vertcdemo.core.annotation.RoleType.AUDIENCE;
import static com.vertcdemo.core.annotation.RoleType.HOST;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({AUDIENCE, HOST})
@Retention(RetentionPolicy.SOURCE)
public @interface RoleType {
    int AUDIENCE = 1;
    int HOST = 2;

}
