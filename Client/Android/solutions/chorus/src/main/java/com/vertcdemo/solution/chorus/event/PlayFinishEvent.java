// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

public class PlayFinishEvent {

    public final String songId;

    public PlayFinishEvent(String songId) {
        this.songId = songId;
    }
}
