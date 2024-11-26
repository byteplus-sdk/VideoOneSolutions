// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;

public class FinishSingBroadcast {
    @SerializedName("score")
    public float score;
    @SerializedName("next_song")
    public PickedSongInfo nextSong;

    @SerializedName("cur_song")
    public PickedSongInfo currentSong;

    @Override
    public String toString() {
        return "FinishSingBroadcast{" +
                "score=" + score +
                ", nextSong=" + nextSong +
                '}';
    }
}
