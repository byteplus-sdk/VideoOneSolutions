// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatStatus;

public class SeatChangedBroadcast {

    @SerializedName("seat_id")
    public int seatId;
    @SerializedName("type")
    @SeatStatus
    public int type;

    @Override
    public String toString() {
        return "SeatChangedEvent{" +
                "seatId=" + seatId +
                ", type=" + type +
                '}';
    }
}
