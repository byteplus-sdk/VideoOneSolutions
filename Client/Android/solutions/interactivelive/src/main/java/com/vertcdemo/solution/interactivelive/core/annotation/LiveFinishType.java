// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        LiveFinishType.NORMAL,
        LiveFinishType.TIMEOUT,
        LiveFinishType.IRREGULARITY
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveFinishType {
    int NORMAL = 1;
    int TIMEOUT = 2;
    int IRREGULARITY = 3;
}
