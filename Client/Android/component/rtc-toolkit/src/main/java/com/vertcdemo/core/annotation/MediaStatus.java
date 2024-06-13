// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({MediaStatus.ON, MediaStatus.OFF, MediaStatus.KEEP})
@Retention(RetentionPolicy.SOURCE)
public @interface MediaStatus {
    int KEEP = -1;
    int ON = 1;
    int OFF = 0;
}
