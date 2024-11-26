// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({CompleteAction.LOOP, CompleteAction.NEXT})
@Retention(RetentionPolicy.SOURCE)
public @interface CompleteAction {
    int LOOP = 0;
    int NEXT = 1;
}
