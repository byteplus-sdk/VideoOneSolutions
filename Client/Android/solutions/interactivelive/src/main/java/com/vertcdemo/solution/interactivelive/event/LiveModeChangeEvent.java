// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;

public class LiveModeChangeEvent {
    @LiveMode
    public final int liveMode;

    public LiveModeChangeEvent(@LiveMode int liveMode) {
        this.liveMode = liveMode;
    }
}
