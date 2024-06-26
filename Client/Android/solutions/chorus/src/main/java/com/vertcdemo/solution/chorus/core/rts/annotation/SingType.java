// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.core.rts.annotation;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


@StringDef({SingType.SOLO, SingType.CHORUS})
@Retention(RetentionPolicy.SOURCE)
public @interface SingType {
    String SOLO = "1";

    String CHORUS = "2";
}
