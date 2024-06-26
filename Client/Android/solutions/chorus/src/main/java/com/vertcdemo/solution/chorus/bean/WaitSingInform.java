// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

@RTSInform
public class WaitSingInform {
    @SerializedName("song")
    public PickedSongInfo song;//为空则点歌列表空了
    @SerializedName("leader_user")
    public UserInfo leader;
    @SerializedName("user_id")
    public String operateUid;//操作者

    @Override
    public String toString() {
        return "WaitSingInform{" +
                "song=" + song +
                ", leader=" + leader +
                ", operateUid='" + operateUid + '\'' +
                '}';
    }
}
