// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

@RTSResponse
public class CreateRoomResponse {

    @SerializedName("room_info")
    public RoomInfo roomInfo;
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;

    @NonNull
    @Override
    public String toString() {
        return "CreateRoomResponse{" +
                "roomInfo=" + roomInfo +
                ", userInfo=" + userInfo +
                ", rtcToken='" + rtcToken + '\'' +
                '}';
    }
}
