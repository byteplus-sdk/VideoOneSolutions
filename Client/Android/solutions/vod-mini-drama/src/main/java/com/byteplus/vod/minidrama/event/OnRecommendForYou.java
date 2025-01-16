// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;

public class OnRecommendForYou {
    public final DramaInfo dramaInfo;
    public final int episodeNumber;

    public OnRecommendForYou(DramaRecommend recommend) {
        this.dramaInfo = recommend.info;
        this.episodeNumber = recommend.feed.episodeNumber;
    }
}
