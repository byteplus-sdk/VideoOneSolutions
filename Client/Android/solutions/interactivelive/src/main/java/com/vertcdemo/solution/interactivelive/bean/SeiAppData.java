// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;

public class SeiAppData {
    @SerializedName("liveMode")
    @LiveMode
    public int liveMode = LiveMode.NORMAL;

    public int getLiveMode() {
        return liveMode == 0 ? LiveMode.NORMAL : liveMode;
    }
}
