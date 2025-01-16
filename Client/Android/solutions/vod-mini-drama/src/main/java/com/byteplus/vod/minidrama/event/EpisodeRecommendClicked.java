// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;

public class EpisodeRecommendClicked {
    public final DramaRecommend recommend;

    private EpisodeRecommendClicked(DramaRecommend recommend) {
        this.recommend = recommend;
    }

    public static class Text extends EpisodeRecommendClicked {
        public Text(DramaRecommend recommend) {
            super(recommend);
        }
    }

    public static class Cover extends EpisodeRecommendClicked {
        public Cover(DramaRecommend recommend) {
            super(recommend);
        }
    }

    public static EpisodeRecommendClicked text(DramaRecommend recommend) {
        return new Text(recommend);
    }

    public static EpisodeRecommendClicked cover(DramaRecommend recommend) {
        return new Cover(recommend);
    }
}
