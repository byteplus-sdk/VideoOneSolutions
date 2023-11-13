// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({LivePermitType.ACCEPT, LivePermitType.REJECT})
@Retention(RetentionPolicy.SOURCE)
public @interface LivePermitType {
    int ACCEPT = 1;
    int REJECT = 2;
}
