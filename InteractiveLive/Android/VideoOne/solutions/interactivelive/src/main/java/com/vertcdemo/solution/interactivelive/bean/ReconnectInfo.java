// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;

import java.util.List;
import java.util.Map;

/**
 * Data model of reconnect information
 */
public class ReconnectInfo {

    @SerializedName("live_room_info")
    public LiveRoomInfo liveRoomInfo;
    @SerializedName("audience_count")
    public int audienceCount;
    @SerializedName("stream_push_url")
    public String streamPushUrl;
    @SerializedName("stream_pull_url")
    public Map<String, String> streamPullUrl;
    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("rtc_user_list")
    public List<LiveUserInfo> rtcUserList;

    @Override
    public String toString() {
        return "ReconnectInfo{" +
                "liveRoomInfo=" + liveRoomInfo +
                ", audienceCount=" + audienceCount +
                ", streamPushUrl='" + streamPushUrl + '\'' +
                ", streamPullUrl=" + streamPullUrl +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", rtcToken='" + rtcToken + '\'' +
                ", rtcUserList=" + rtcUserList +
                '}';
    }
}
