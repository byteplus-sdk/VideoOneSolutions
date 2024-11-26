// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.http.response;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.bean.SeatInfo;
import com.vertcdemo.solution.ktv.bean.UserInfo;

import java.util.Map;

public class JoinRoomResponse {
    @SerializedName("room_info")
    public RoomInfo roomInfo;
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("host_info")
    public UserInfo hostInfo;
    @SerializedName("seat_list")
    public Map<Integer, SeatInfo> seatMap;
    @SerializedName("audience_count")
    public int audienceCount;

    @SerializedName("cur_song")
    public PickedSongInfo current;

    @NonNull
    @Override
    public String toString() {
        return "JoinRoomResponse{" +
                "roomInfo=" + roomInfo +
                ", userInfo=" + userInfo +
                ", rtcToken='" + rtcToken + '\'' +
                ", hostInfo=" + hostInfo +
                ", seatMap=" + seatMap +
                ", audienceCount=" + audienceCount +
                '}';
    }
}
