// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

public class EpisodePlayStateChanged {
    public final String dramaId;
    public final int from;
    public final int to;

    public EpisodePlayStateChanged(String dramaId, int from, int to) {
        this.dramaId = dramaId;
        this.from = from == to ? -1 : from;
        this.to = to;
    }
}
