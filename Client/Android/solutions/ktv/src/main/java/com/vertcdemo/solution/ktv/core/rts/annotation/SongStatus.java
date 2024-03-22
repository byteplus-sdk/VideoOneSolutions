// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core.rts.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        SongStatus.WAITING,
        SongStatus.SINGING,
        SongStatus.FINISH,
        SongStatus.NOT_DOWNLOAD,
        SongStatus.DOWNLOADING,
        SongStatus.PICKED,
        SongStatus.DOWNLOADED})
@Retention(RetentionPolicy.SOURCE)
public @interface SongStatus {

    /**
     * WAITING
     */
    int WAITING = 1;
    /**
     * SINGING
     */
    int SINGING = 2;
    /**
     * FINISH, wait next track
     */
    int FINISH = 3;
    /**
     * NOT PICK and NOT DOWNLOADED
     */
    int NOT_DOWNLOAD = 4;
    /**
     * PICKED and DOWNLOADING
     */
    int DOWNLOADING = 5;
    /**
     * PICKED and DOWNLOADED
     */
    int PICKED = 6;

    int DOWNLOADED = 7;
}
