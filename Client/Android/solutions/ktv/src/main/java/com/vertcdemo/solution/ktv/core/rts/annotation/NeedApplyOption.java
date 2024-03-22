// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        NeedApplyOption.NEED,
        NeedApplyOption.NO_NEED,
})
@Retention(RetentionPolicy.SOURCE)
public @interface NeedApplyOption {
    int NEED = 1;
    int NO_NEED = 2;
}