// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import androidx.annotation.IntDef;

import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({RoomStatus.LIVE, RoomStatus.AUDIENCE_LINK, RoomStatus.PK})
@Retention(RetentionPolicy.SOURCE)
public @interface RoomStatus {
    int LIVE = LiveLinkMicStatus.OTHER;
    int AUDIENCE_LINK = LiveLinkMicStatus.AUDIENCE_INTERACTING;
    int PK = LiveLinkMicStatus.HOST_INTERACTING;
}
