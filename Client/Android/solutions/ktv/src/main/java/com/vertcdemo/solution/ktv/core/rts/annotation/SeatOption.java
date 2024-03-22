// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


@IntDef({
        SeatOption.LOCK,
        SeatOption.UNLOCK,
        SeatOption.MIC_OFF,
        SeatOption.MIC_ON,
        SeatOption.END_INTERACT,
})
@Retention(RetentionPolicy.SOURCE)
public @interface SeatOption {
    int LOCK = 1;
    int UNLOCK = 2;
    int MIC_OFF = 3;
    int MIC_ON = 4;
    int END_INTERACT = 5;
}
