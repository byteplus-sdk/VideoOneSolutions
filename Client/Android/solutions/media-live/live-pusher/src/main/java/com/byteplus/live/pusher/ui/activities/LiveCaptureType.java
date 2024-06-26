// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.pusher.ui.activities;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        LiveCaptureType.CAMERA,
        LiveCaptureType.AUDIO,
        LiveCaptureType.SCREEN,
        LiveCaptureType.FILE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface LiveCaptureType {
    int CAMERA = 0;
    int AUDIO = 1;
    int SCREEN = 2;
    int FILE = 3;
}
