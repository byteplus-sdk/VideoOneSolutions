// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DramaRecommend implements Serializable {
    public static final String EXTRA_DRAMA_RECOMMEND = "extra_drama_recommend";

    @SerializedName("drama_meta")
    public DramaInfo info;
    @SerializedName("video_meta")
    public DramaFeed feed;

    public DramaRecommend(DramaInfo info, DramaFeed feed) {
        this.info = info;
        this.feed = feed;
    }

    public String getDramaId() {
        return info == null ? "" : info.dramaId;
    }

    public int getEpisodeCount() {
        return info == null ? 0 : info.totalEpisodeNumber;
    }

    public DisplayType getDisplayType() {
        return info == null ? DisplayType.TEXT : feed.displayType;
    }

    public String getDramaTitle() {
        return info == null ? "" : info.dramaTitle;
    }

    public int getEpisodeNumber() {
        return feed == null ? 0 : feed.episodeNumber;
    }

    public int getDramaPlayTimes() {
        return info == null ? 0 : info.dramaPlayTimes;
    }

    public String getDramaCover() {
        return info == null ? "" : info.dramaCoverUrl;
    }

    public String getEpisodeTitle() {
        return feed == null ? "" : feed.title;
    }

    public String getEpisodeSubtitle() {
        return feed == null ? "" : feed.subtitle;
    }

    public static DramaRecommend of(@Nullable VideoItem item) {
        if (item == null) {
            return null;
        }
        return item.getExtra(EXTRA_DRAMA_RECOMMEND, DramaRecommend.class);
    }

    public static List<VideoItem> toVideoItems(@Nullable List<? extends DramaRecommend> items) {
        if (items == null || items.isEmpty()) {
            return Collections.emptyList();
        }

        List<VideoItem> videoItems = new ArrayList<>();
        for (DramaRecommend item : items) {
            if (item.info == null) {
                continue;
            }

            VideoItem videoItem = item.feed.toVideoItem();
            videoItem.putExtra(EXTRA_DRAMA_RECOMMEND, item);
            videoItems.add(videoItem);
        }

        return videoItems;
    }
}