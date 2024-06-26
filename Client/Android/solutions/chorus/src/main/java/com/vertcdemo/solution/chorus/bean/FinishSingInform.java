// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

@RTSInform
public class FinishSingInform {
    @SerializedName("score")
    public float score;
    @SerializedName("next_song")
    public PickedSongInfo nextSong;//下一首歌曲，如果为空则无下一首
    @SerializedName("user_id")
    public String operateUid;//操作者

    @Override
    public String toString() {
        return "FinishSingInform{" +
                "score=" + score +
                ", nextSong=" + nextSong +
                '}';
    }
}
