// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

public class StartSingInform {
    @SerializedName("song")
    public PickedSongInfo song;//如果song为空，点的歌曲已经全部演唱完，返回原始点歌台
    @SerializedName("leader_user")
    public UserInfo leader;
    @Nullable
    @SerializedName("succentor_user")
    public UserInfo supporting;//副唱为空则为独唱
    @SerializedName("user_id")
    public String operateUid;//操作者

    @NonNull
    @Override
    public String toString() {
        return "StartSingInform{" +
                "song=" + song +
                ", leader=" + leader +
                ", supporting=" + supporting +
                ", operateUid='" + operateUid + '\'' +
                '}';
    }
}
