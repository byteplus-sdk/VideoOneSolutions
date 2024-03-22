// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;

import com.vertcdemo.solution.ktv.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SongStatus;

import java.util.Arrays;
import java.util.HashSet;

public class DownloadStatusChanged {
    public final HashSet<String> roomIds;
    public final String songId;
    @DownloadType
    public final int type;
    @SongStatus
    public final int status;

    public DownloadStatusChanged(@NonNull HashSet<String> roomIds,
                                 String songId,
                                 @DownloadType int type) {
        this(roomIds, songId, type, SongStatus.DOWNLOADED);
    }

    public DownloadStatusChanged(@NonNull HashSet<String> roomIds,
                                 String songId,
                                 @DownloadType int type,
                                 @SongStatus int status) {
        this.roomIds = roomIds;
        this.songId = songId;
        this.type = type;
        this.status = status;
    }
}
