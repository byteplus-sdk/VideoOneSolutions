// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;

public class PickedSongInfo {
    @SerializedName("room_id")
    public String roomId;
    @SerializedName("song_id")
    public String songId;
    @SerializedName("song_name")
    public String songName;
    @SerializedName("owner_user_id")
    public String ownerUid;
    @SerializedName("owner_user_name")
    public String ownerUserName;
    @SerializedName("song_duration")
    public int duration;
    @SerializedName("cover_url")
    public String coverUrl;
    @SongStatus
    @SerializedName("status")
    public int status;

    @NonNull
    @Override
    public String toString() {
        return "PickedSongInfo{" +
                "roomId='" + roomId + '\'' +
                ", songId='" + songId + '\'' +
                ", songName='" + songName + '\'' +
                ", ownerUid='" + ownerUid + '\'' +
                ", ownerUserName='" + ownerUserName + '\'' +
                ", duration=" + duration +
                ", coverUrl='" + coverUrl + '\'' +
                ", status=" + status +
                '}';
    }
}