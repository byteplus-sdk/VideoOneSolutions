// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;


import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class DramaInfo implements Serializable {
    @SerializedName("drama_id")
    public String dramaId;
    @SerializedName("drama_title")
    public String dramaTitle; // Drama name
    @SerializedName(value = "drama_cover_url")
    public String dramaCoverUrl; // Drama cover
    @SerializedName(value = "new_release")
    public boolean newRelease; // New release mark
    @SerializedName(value = "drama_play_times")
    public int dramaPlayTimes;
    @SerializedName(value = "drama_video_orientation")
    public Orientation orientation = Orientation.PORTRAIT;
    @SerializedName("drama_length")
    public int totalEpisodeNumber;

    @NonNull
    @Override
    public String toString() {
        return "DramaInfo{" +
                "dramaId='" + dramaId + '\'' +
                ", dramaTitle='" + dramaTitle + '\'' +
                ", dramaCoverUrl='" + dramaCoverUrl + '\'' +
                ", dramaPlayTimes=" + dramaPlayTimes +
                '}';
    }

    public enum Orientation {
        @SerializedName("0")
        PORTRAIT,
        @SerializedName("1")
        LANDSCAPE
    }
}
