// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.feature.main.RoomStatus;

import java.io.Serializable;
import java.util.Map;

/**
 * Room data model
 */
public class LiveRoomInfo implements Serializable {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("room_name")
    public String roomName;
    @SerializedName("host_user_id")
    public String anchorUserId;
    @SerializedName("host_user_name")
    public String anchorUserName;
    @RoomStatus
    @SerializedName("status")
    public int status;
    @SerializedName("audience_count")
    public int audienceCount;
    @SerializedName("start_time")
    public long startTime;
    @SerializedName("stream_pull_url_list")
    public Map<String, String> streamPullStreamList;

    @SerializedName("extra")
    public String extra;

    @NonNull
    @Override
    public String toString() {
        return "LiveRoomInfo{" +
                "roomId='" + roomId + '\'' +
                ", roomName='" + roomName + '\'' +
                ", anchorUserId='" + anchorUserId + '\'' +
                ", anchorUserName='" + anchorUserName + '\'' +
                ", status=" + status +
                ", audienceCount=" + audienceCount +
                ", startTime=" + startTime +
                ", streamPullStreamList=" + streamPullStreamList +
                '}';
    }
}
