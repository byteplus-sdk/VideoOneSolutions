// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;

import java.util.Collections;
import java.util.List;

public class GetPickedSongListResponse {
    @SerializedName("song_list")
    public List<PickedSongInfo> songList;

    @NonNull
    public static List<PickedSongInfo> songs(@Nullable GetPickedSongListResponse response) {
        if (response == null || response.songList == null) {
            return Collections.emptyList();
        }
        return response.songList;
    }
}
