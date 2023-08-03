// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login.utils;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

@SuppressWarnings("unused")
@Keep
public class AgreementManager {
    public interface ResultCallback {
        void onResult(boolean result);
    }

    public static <T extends AppCompatActivity & ResultCallback> void check(@NonNull T activity) {
        activity.onResult(true);
    }
}
