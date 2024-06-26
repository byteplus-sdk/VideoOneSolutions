// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        DownloadType.LRC,
        DownloadType.MUSIC
})
@Retention(RetentionPolicy.SOURCE)
public @interface DownloadType {

    int LRC = 1;
    int MUSIC = 2;

}
