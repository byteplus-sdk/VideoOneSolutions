// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.annotation;

import static com.vertcdemo.core.annotation.CameraStatus.OFF;
import static com.vertcdemo.core.annotation.CameraStatus.ON;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({OFF, ON})
@Retention(RetentionPolicy.SOURCE)
public @interface CameraStatus {
    int OFF = 0;
    int ON = 1;
}