// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GetRequestSongResponse {
    @SerializedName("song_list")
    public List<PickedSongInfo> songList;
}
