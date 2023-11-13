// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.Collections;
import java.util.List;

/**
 * The data model returned by the room list interface
 */
@RTSResponse
public class LiveRoomListResponse {
    @SerializedName("live_room_list")
    public List<LiveRoomInfo> roomList;

    @NonNull
    public List<LiveRoomInfo> getRoomList() {
        return roomList == null ? Collections.emptyList() : roomList;
    }
}
