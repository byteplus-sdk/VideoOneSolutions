// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({NeedApply.ON, NeedApply.OFF})
@Retention(RetentionPolicy.SOURCE)
public @interface NeedApply {
    /**
     * OFF means no need to Apply
     */
    int OFF = 0;
    /**
     * ON means need Apply before take the seat
     */
    int ON = 1;
}
