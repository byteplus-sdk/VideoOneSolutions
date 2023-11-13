// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

/**
 * Create the data model returned by the live room interface
 */
@RTSResponse
public class CreateLiveRoomResponse {

    @SerializedName("live_room_info")
    public LiveRoomInfo liveRoomInfo;
    @SerializedName("user_info")
    public LiveUserInfo userInfo;
    @SerializedName("stream_push_url")
    public String streamPushUrl;
    @SerializedName(value = "rts_token", alternate = {"rtm_token"})
    public String rtsToken;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("rtc_room_id")
    public String rtcRoomId;

    @Override
    public String toString() {
        return "CreateLiveRoomResponse{" +
                "liveRoomInfo=" + liveRoomInfo +
                ", userInfo=" + userInfo +
                ", streamPushUrl='" + streamPushUrl + '\'' +
                ", rtsToken='" + rtsToken + '\'' +
                ", rtcToken='" + rtcToken + '\'' +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                '}';
    }
}
