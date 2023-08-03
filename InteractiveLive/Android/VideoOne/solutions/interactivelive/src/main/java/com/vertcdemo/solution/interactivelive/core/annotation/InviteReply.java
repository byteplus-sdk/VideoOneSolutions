// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({InviteReply.WAITING, InviteReply.ACCEPT, InviteReply.REJECT, InviteReply.TIMEOUT})
@Retention(RetentionPolicy.SOURCE)
public @interface InviteReply {
    int WAITING = 0;
    int ACCEPT = 1;
    int REJECT = 2;
    int TIMEOUT = 3;
}
