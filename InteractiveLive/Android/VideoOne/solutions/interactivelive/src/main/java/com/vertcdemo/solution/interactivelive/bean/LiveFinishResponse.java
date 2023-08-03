// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.rts.RTSResponse;

@RTSResponse
public class LiveFinishResponse {
    @SerializedName("live_room_info")
    public LiveRoomInfo liveRoomInfo;

    @NonNull
    public LiveSummary getLiveSummary() {
        if (liveRoomInfo == null || liveRoomInfo.extra == null) {
            return new LiveSummary();
        } else {
            return GsonUtils.gson().fromJson(liveRoomInfo.extra, LiveSummary.class);
        }
    }
}
