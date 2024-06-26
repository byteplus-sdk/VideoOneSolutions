// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.Collections;
import java.util.List;

@RTSResponse
public class GetPresetSongListResponse {
    @SerializedName("song_list")
    public List<SongItem> songs;

    @NonNull
    public List<SongItem> getSongs() {
        return songs == null ? Collections.emptyList() : songs;
    }
}
