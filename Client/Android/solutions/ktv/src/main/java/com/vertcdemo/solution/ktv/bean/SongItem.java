// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

@RTSResponse
public class SongItem {
    @SerializedName("artist")
    public String artist;
    @SerializedName("cover_url")
    public String coverUrl;
    @SerializedName("song_duration")
    public int duration;
    @SerializedName("song_lrc_url")
    public String songLrcUrl;
    @SerializedName("song_file_url")
    public String songFileUrl;
    @SerializedName("song_id")
    public String songId;
    @SerializedName("song_name")
    public String songName;

    @NonNull
    @Override
    public String toString() {
        return "SongItem{" +
                "artist='" + artist + '\'' +
                ", coverUrl='" + coverUrl + '\'' +
                ", duration=" + duration +
                ", songLrcUrl='" + songLrcUrl + '\'' +
                ", songFileUrl='" + songFileUrl + '\'' +
                ", songId='" + songId + '\'' +
                ", songName='" + songName + '\'' +
                '}';
    }
}
