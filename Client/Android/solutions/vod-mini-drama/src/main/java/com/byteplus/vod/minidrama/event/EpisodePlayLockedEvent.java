// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

import com.byteplus.vod.scenekit.data.model.VideoItem;

public class EpisodePlayLockedEvent {
    public final VideoItem videoItem;

    public EpisodePlayLockedEvent(VideoItem videoItem) {
        this.videoItem = videoItem;
    }
}
