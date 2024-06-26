// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.bean;


import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;

public class StatusPickedSongItem {
    public PickedSongInfo item;

    public int status;

    public boolean isSinging() {
        return status == SongStatus.SINGING;
    }

    public StatusPickedSongItem(PickedSongInfo item) {
        this.item = item;
    }

    public StatusPickedSongItem(PickedSongInfo item, boolean isPlaying) {
        this.item = item;
        this.status = isPlaying ? SongStatus.SINGING : SongStatus.PICKED;
    }

    public String getSongId() {
        return item.songId;
    }

    public String getOwnerUid() {
        return item.ownerUid;
    }

    public String getSongName() {
        return item.songName;
    }

    public String getCoverUrl() {
        return item.coverUrl;
    }

    public String getArtist() {
        return item.ownerUserName;
    }
}
