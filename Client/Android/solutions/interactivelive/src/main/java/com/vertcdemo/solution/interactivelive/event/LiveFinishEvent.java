// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveFinishType;
import com.vertcdemo.solution.interactivelive.bean.LiveSummary;

/**
 * Live end event
 */
@RTSInform
public class LiveFinishEvent {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("type")
    @LiveFinishType
    public int type;

    @SerializedName("extra")
    public String extra;

    @NonNull
    public LiveSummary getLiveSummary() {
        if (this.extra == null) {
            return new LiveSummary();
        } else {
            return GsonUtils.gson().fromJson(this.extra, LiveSummary.class);
        }
    }

    @Override
    public String toString() {
        return "LiveFinishEvent{" +
                "roomId='" + roomId + '\'' +
                ", type=" + type +
                '}';
    }
}
