// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.annotation;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@StringDef({
        LiveResolution.RES480,
        LiveResolution.RES540,
        LiveResolution.RES720,
        LiveResolution.RES1080,
        LiveResolution.RES_ORIGIN,
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveResolution {
    String RES480 = "480";
    String RES540 = "540";
    String RES720 = "720";
    String RES1080 = "1080";
    String RES_ORIGIN = "origin";
}
