// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        GiftType.LIKE,
        GiftType.SUGAR,
        GiftType.DIAMOND,
        GiftType.FIREWORKS,
})
@Retention(RetentionPolicy.SOURCE)
public @interface GiftType {
    int NONE = 0;
    int LIKE = 1;
    int SUGAR = 2;
    int DIAMOND = 3;
    int FIREWORKS = 4;
}
