// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class DramaFeed implements Serializable {

    public static final String EXTRA_DRAMA_FEED = "extra_drama_feed";

    @SerializedName("vid")
    public String vid;

    @SerializedName("caption")
    public String title;

    @SerializedName("duration")
    public double duration;

    @SerializedName("cover_url")
    public String coverUrl;

    @SerializedName("play_auth_token")
    public String playAuthToken;

    @SerializedName("subtitle_auth_token")
    public String subtitleAuthToken;

    @SerializedName("play_times")
    public int playTimes;

    @SerializedName("subtitle")
    public String subtitle;

    @SerializedName("create_time")
    public Date createTime;

    @SerializedName("name")
    public String userName;

    @SerializedName("uid")
    public String userId;

    @SerializedName("like")
    public int likeCount;

    @SerializedName("comment")
    public int commentCount;

    @SerializedName("height")
    public int height;

    @SerializedName("width")
    public int width;

    @SerializedName("order")
    public int episodeNumber;

    @SerializedName("drama_id")
    public String dramaId;

    @SerializedName("vip")
    public boolean needVip;

    @SerializedName("display_type")
    public DisplayType displayType = DisplayType.TEXT;

    public boolean isLocked() {
        return needVip || TextUtils.isEmpty(playAuthToken);
    }

    public VideoItem toVideoItem() {
        VideoItem videoItem = VideoItem.createVidItem(
                vid,
                playAuthToken,
                subtitleAuthToken,
                (long) (duration * 1000),
                coverUrl,
                title);

        videoItem.setSubtitle(subtitle);
        videoItem.setPlayCount(playTimes);
        videoItem.setCreateTime(createTime);
        videoItem.setSize(width, height);
        videoItem.setUser(userId, userName);
        videoItem.setLikeCount(likeCount);
        videoItem.setCommentCount(commentCount);

        videoItem.putExtra(EXTRA_DRAMA_FEED, this);

        return videoItem;
    }

    public void updatePlayAuthToken(String authToken) {
        this.needVip = TextUtils.isEmpty(authToken);
        this.playAuthToken = authToken;
    }

    public void updateSubtitleAuthToken(String authToken) {
        this.subtitleAuthToken = authToken;
    }

    public static DramaFeed of(VideoItem item) {
        return item.getExtra(EXTRA_DRAMA_FEED, DramaFeed.class);
    }

    @NonNull
    public static List<VideoItem> toVideoItems(List<? extends DramaFeed> items) {
        if (items == null || items.isEmpty()) {
            return Collections.emptyList();
        }
        List<VideoItem> videoItems = new ArrayList<>();
        for (DramaFeed item : items) {
            videoItems.add(item.toVideoItem());
        }

        return videoItems;
    }

    public static boolean isLocked(VideoItem item) {
        DramaFeed feed = of(item);
        return feed != null && feed.isLocked();
    }

    public static int findPositionByEpisodeNumber(List<ViewItem> items, int episodeNumber) {
        for (int i = 0; items != null && i < items.size(); i++) {
            ViewItem item = items.get(i);
            if (item instanceof VideoItem videoItem) {
                DramaFeed feed = of(videoItem);
                if (feed != null && feed.episodeNumber == episodeNumber) {
                    return i;
                }
            }
        }
        return -1;
    }
}
