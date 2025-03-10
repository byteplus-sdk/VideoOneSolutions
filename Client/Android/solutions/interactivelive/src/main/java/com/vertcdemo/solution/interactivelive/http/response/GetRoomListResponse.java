// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.solution.interactivelive.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;

import java.util.Collections;
import java.util.List;

public class GetRoomListResponse {
    @SerializedName("live_room_list")
    public List<LiveRoomInfo> rooms;

    @NonNull
    public static List<LiveRoomInfo> rooms(@Nullable GetRoomListResponse response) {
        if (response == null || response.rooms == null) {
            return Collections.emptyList();
        }
        return response.rooms;
    }
}
