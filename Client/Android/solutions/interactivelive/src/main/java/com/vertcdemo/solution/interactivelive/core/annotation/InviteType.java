// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({InviteType.GUEST_APPLY, InviteType.HOST_INVITE_GUEST, InviteType.HOST_INVITE_HOST, InviteType.HOST_PK})
@Retention(RetentionPolicy.SOURCE)
public @interface InviteType {
    int GUEST_APPLY = 1;
    int HOST_INVITE_GUEST = 2;
    int HOST_INVITE_HOST = 3;
    int HOST_PK = 4;
}
