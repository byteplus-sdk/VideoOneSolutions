// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        GuestManageType.DISCONNECT,
        GuestManageType.CLOSE_MIC,
        GuestManageType.CLOSE_CAMERA
})
@Retention(RetentionPolicy.SOURCE)
public @interface GuestManageType {
    int DISCONNECT = 1;
    int CLOSE_MIC = 2;
    int CLOSE_CAMERA = 3;
}
