// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.bean;


import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;

public class StatusSongItem {
    public final SongItem item;

    @SongStatus
    public int status = SongStatus.NOT_DOWNLOAD;

    public StatusSongItem(SongItem item) {
        this.item = item;
    }

    public String getSongId() {
        return item.songId;
    }

    public String getSongName() {
        return item.songName;
    }

    public String getCoverUrl() {
        return item.coverUrl;
    }

    public String getArtist() {
        return item.artist;
    }

    public StatusSongItem copy(@SongStatus int status) {
        StatusSongItem other = new StatusSongItem(this.item);
        other.status = status;
        return other;
    }
}