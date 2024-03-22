// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


@IntDef({
        FinishType.NORMAL,
        FinishType.TIMEOUT,
        FinishType.BLOCKED,
})
@Retention(RetentionPolicy.SOURCE)
public @interface FinishType {
    int NORMAL = 1;
    int TIMEOUT = 2;
    int BLOCKED = 3;
}