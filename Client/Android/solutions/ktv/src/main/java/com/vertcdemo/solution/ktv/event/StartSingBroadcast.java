// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;

@RTSInform
public class StartSingBroadcast {
    @SerializedName("song")
    public PickedSongInfo song;

    @Override
    public String toString() {
        return "StartSingBroadcast{" +
                "song=" + song +
                '}';
    }
}
