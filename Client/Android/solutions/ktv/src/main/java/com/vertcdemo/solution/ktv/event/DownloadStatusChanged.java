// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.solution.ktv.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SongStatus;

import java.util.Collections;
import java.util.Set;

public class DownloadStatusChanged {
    private final Set<String> roomIds;
    public final String songId;
    @DownloadType
    public final int type;
    @SongStatus
    public final int status;

    public DownloadStatusChanged(@NonNull String roomId,
                                 String songId,
                                 @DownloadType int type) {
        this(Collections.singleton(roomId), songId, type, SongStatus.DOWNLOADED);
    }

    public DownloadStatusChanged(@NonNull String roomId,
                                 String songId,
                                 @DownloadType int type,
                                 @SongStatus int status) {
        this(Collections.singleton(roomId), songId, type, status);
    }

    public DownloadStatusChanged(@NonNull Set<String> roomIds,
                                 String songId,
                                 @DownloadType int type,
                                 @SongStatus int status) {
        this.roomIds = roomIds;
        this.songId = songId;
        this.type = type;
        this.status = status;
    }

    public boolean contains(@Nullable String roomId) {
        return roomIds.contains(roomId);
    }
}
