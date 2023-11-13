// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        LiveMode.NORMAL,
        LiveMode.LINK_PK,
        LiveMode.LINK_1v1,
        LiveMode.LINK_1vN,
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveMode {
    int NORMAL = 1;
    int LINK_PK = 2;
    int LINK_1v1 = 3;
    int LINK_1vN = 4;
}
