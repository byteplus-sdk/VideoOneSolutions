// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

/**
 * Add the data model returned by the live room interface
 */
@RTSResponse
public class JoinLiveRoomResponse {

    @SerializedName("user_info")
    public LiveUserInfo liveUserInfo;
    @SerializedName("host_user_info")
    public LiveUserInfo liveHostUserInfo;
    @SerializedName("live_room_info")
    public LiveRoomInfo liveRoomInfo;
    @SerializedName(value = "rts_token", alternate = {"rtm_token"})
    public String rtsToken;

    @Override
    public String toString() {
        return "JoinLiveRoomResponse{" +
                "liveUserInfo=" + liveUserInfo +
                ", liveHostUserInfo=" + liveHostUserInfo +
                ", liveRoomInfo=" + liveRoomInfo +
                ", rtsToken='" + rtsToken + '\'' +
                '}';
    }
}
