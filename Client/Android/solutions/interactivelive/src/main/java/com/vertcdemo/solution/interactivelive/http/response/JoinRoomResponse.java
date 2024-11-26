// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.http.response;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.feature.main.RoomStatus;

/**
 * Add the data model returned by the live room interface
 */
public class JoinRoomResponse {

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
        return "JoinRoomResponse{" +
                "liveUserInfo=" + liveUserInfo +
                ", liveHostUserInfo=" + liveHostUserInfo +
                ", liveRoomInfo=" + liveRoomInfo +
                ", rtsToken='" + rtsToken + '\'' +
                '}';
    }

    @RoomStatus
    public int getRoomStatus() {
        if (liveHostUserInfo == null) {
            return RoomStatus.LIVE;
        }
        int linkMicStatus = liveHostUserInfo.linkMicStatus;
        switch (linkMicStatus) {
            case LiveLinkMicStatus.AUDIENCE_INTERACTING:
                return RoomStatus.AUDIENCE_LINK;
            case LiveLinkMicStatus.HOST_INTERACTING:
                return RoomStatus.PK;
            default:
                return RoomStatus.LIVE;
        }
    }
}
