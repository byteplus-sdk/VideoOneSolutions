// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

public class EpisodeUserSelectedEvent {
    public final String dramaId;
    public final int episodeNumber;

    public EpisodeUserSelectedEvent(String dramaId, int index) {
        this.dramaId = dramaId;
        this.episodeNumber = index;
    }
}
