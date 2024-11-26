// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.settingskit;

import androidx.annotation.Nullable;

public interface Options {
    interface UserValues {

        @Nullable
        Object getValue(Option option);

        void saveValue(Option option, @Nullable Object value);
    }

    Option option(String key);
}
