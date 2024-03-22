// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;

@RTSInform
public class RequestSongBroadcast {
    @SerializedName("song")
    public PickedSongInfo song;
    @SerializedName("song_count")
    public int songCount;

    @Override
    public String toString() {
        return "RequestSongBroadcast{" +
                "song=" + song +
                ", songCount=" + songCount +
                '}';
    }
}
