// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.SongItem;

import java.util.Collections;
import java.util.List;

public class GetPresetSongListResponse {
    @SerializedName("song_list")
    public List<SongItem> songs;

    @NonNull
    public static List<SongItem> songs(@Nullable GetPresetSongListResponse response) {
        if (response == null || response.songs == null) {
            return Collections.emptyList();
        }
        return response.songs;
    }
}
