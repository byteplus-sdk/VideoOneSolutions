// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        LiveLinkMicStatus.OTHER,
        LiveLinkMicStatus.INVITING,
        LiveLinkMicStatus.APPLYING,
        LiveLinkMicStatus.AUDIENCE_INTERACTING,
        LiveLinkMicStatus.HOST_INTERACTING
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveLinkMicStatus {
    int OTHER = 0;
    int INVITING = 1;
    int APPLYING = 2;
    int AUDIENCE_INTERACTING = 3;
    int HOST_INTERACTING = 4;
}
