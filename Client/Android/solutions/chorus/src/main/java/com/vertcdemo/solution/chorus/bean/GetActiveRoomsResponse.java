// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.List;

@RTSResponse
public class GetActiveRoomsResponse {

    @SerializedName("room_list")
    public List<RoomInfo> roomList;

    @Override
    public String toString() {
        return "GetActiveRoomsResponse{" +
                "roomList=" + roomList +
                '}';
    }
}
