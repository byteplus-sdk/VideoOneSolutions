// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({InteractType.HOST_END_PK, InteractType.END_CO_HOST, InteractType.GUEST_END, InteractType.HOST_END_ALL})
@Retention(RetentionPolicy.SOURCE)
public @interface InteractType {
    int HOST_END_PK = 1;
    int END_CO_HOST = 2;
    int GUEST_END = 3;
    int HOST_END_ALL = 4;
}
