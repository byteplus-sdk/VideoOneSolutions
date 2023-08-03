// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({RoomStatus.LIVE, RoomStatus.AUDIENCE_LINK, RoomStatus.PK})
@Retention(RetentionPolicy.SOURCE)
public @interface RoomStatus {
    int LIVE = 0;
    int AUDIENCE_LINK = 3;
    int PK = 4;
}
