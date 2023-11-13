// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        MessageType.MSG,
        MessageType.GIFT,
        MessageType.LIKE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface MessageType {
    int MSG = 1;
    int GIFT = 2;
    int LIKE = 3;
}
