// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;

public class PickedSongInform {
    @Override
    public String toString() {
        return "PickedSongInform{" +
                "song=" + song +
                ", songCount=" + songCount +
                ", operateUid='" + operateUid + '\'' +
                '}';
    }

    @SerializedName("song")
    public PickedSongInfo song;//为空则点歌列表空了
    @SerializedName("song_count")
    public int songCount;
    @SerializedName("user_id")
    public String operateUid;//操作者
}
