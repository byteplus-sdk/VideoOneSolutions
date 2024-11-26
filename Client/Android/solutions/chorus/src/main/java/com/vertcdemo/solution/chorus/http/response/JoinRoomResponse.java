// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.http.response;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.bean.UserInfo;

public class JoinRoomResponse {
    @SerializedName("room_info")
    public RoomInfo roomInfo;
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("host_info")
    public UserInfo hostInfo;
    @SerializedName("audience_count")
    public int audienceCount;
    @SerializedName("cur_song")
    public PickedSongInfo current;
    @SerializedName("next_song")
    public PickedSongInfo next;
    @SerializedName("leader_user")
    public UserInfo leaderSinger;
    @SerializedName("succentor_user")
    public UserInfo supportingSinger;

    public boolean isValid() {
        return userInfo != null
                && roomInfo != null
                && hostInfo != null;
    }
}
