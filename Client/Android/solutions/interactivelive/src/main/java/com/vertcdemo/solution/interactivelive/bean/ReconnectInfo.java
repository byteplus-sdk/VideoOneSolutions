// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

import java.util.Collections;
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
    @SerializedName("linkmic_user_list")
    public List<LiveUserInfo> linkMicUsers;
    @Nullable
    @SerializedName(value = "linker_id")
    public String linkerId;

    @Override
    public String toString() {
        return "ReconnectInfo{" +
                "liveRoomInfo=" + liveRoomInfo +
                ", audienceCount=" + audienceCount +
                ", streamPushUrl='" + streamPushUrl + '\'' +
                ", streamPullUrl=" + streamPullUrl +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", rtcToken='" + rtcToken + '\'' +
                '}';
    }

    @NonNull
    public List<LiveUserInfo> getLinkMicUsers() {
        return linkMicUsers == null ? Collections.emptyList() : linkMicUsers;
    }

    @Nullable
    public String getLinkerId() {
        return linkerId;
    }
}
