// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.rtc;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public interface IRTCManager {
    void createEngine(@NonNull String appId, @Nullable String bid);

    void destroyEngine();
}
