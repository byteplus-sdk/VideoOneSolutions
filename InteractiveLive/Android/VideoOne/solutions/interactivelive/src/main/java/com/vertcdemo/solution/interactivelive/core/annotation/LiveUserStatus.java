// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        LiveUserStatus.OTHER,
        LiveUserStatus.HOST_INVITING,
        LiveUserStatus.CO_HOSTING,
        LiveUserStatus.AUDIENCE_INVITING,
        LiveUserStatus.AUDIENCE_INTERACTING
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveUserStatus {
    // Other
    int OTHER = 1;
    // The host is being invited to Lianmai
    int HOST_INVITING = 2;
    // The host is interacting with the host
    int CO_HOSTING = 3;
    // The audience is being invited to Lianmai
    int AUDIENCE_INVITING = 4;
    int AUDIENCE_INTERACTING = 5;
}
