// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.solution.ktv.bean.SeatInfo;

import java.util.Collections;
import java.util.Map;

public class InitSeatDataEvent {
    @NonNull
    public final Map<Integer, SeatInfo> seatMap;

    public InitSeatDataEvent(@Nullable Map<Integer, SeatInfo> seatMap) {
        this.seatMap = seatMap == null ? Collections.emptyMap() : seatMap;
    }
}
