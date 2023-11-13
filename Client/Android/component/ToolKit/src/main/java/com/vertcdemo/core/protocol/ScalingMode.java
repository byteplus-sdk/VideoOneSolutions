// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({ScalingMode.NONE, ScalingMode.ASPECT_FIT, ScalingMode.ASPECT_FILL, ScalingMode.FILL})
@Retention(RetentionPolicy.SOURCE)
public @interface ScalingMode {
    // default
    int NONE = 0;
    // keep aspect to fit
    int ASPECT_FIT = 1;
    // keep aspect to fill
    int ASPECT_FILL = 2;
    // ignore aspect to fill
    int FILL = 3;
}
