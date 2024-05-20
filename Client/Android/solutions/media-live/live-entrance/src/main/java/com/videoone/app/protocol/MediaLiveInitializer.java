// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import android.app.Application;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.byteplus.live.common.AppUtil;

@Keep
public class MediaLiveInitializer implements IInitializer {
    @Override
    public void initialize(@NonNull Application application) {
        AppUtil.initApp(application);
    }
}
