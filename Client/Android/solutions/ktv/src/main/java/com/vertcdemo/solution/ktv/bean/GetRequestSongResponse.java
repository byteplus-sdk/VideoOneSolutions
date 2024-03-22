// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.List;

@RTSResponse
public class GetRequestSongResponse {
    @SerializedName("song_list")
    public List<PickedSongInfo> songList;
}
