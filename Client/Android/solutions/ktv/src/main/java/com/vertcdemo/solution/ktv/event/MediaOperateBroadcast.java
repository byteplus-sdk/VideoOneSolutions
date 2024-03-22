// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.net.rts.RTSInform;

@RTSInform
public class MediaOperateBroadcast {

    @SerializedName("mic")
    @MediaStatus
    public int mic;

    @NonNull
    @Override
    public String toString() {
        return "MediaOperateBroadcast{" +
                "mic=" + mic +
                '}';
    }
}
