// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2.model;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vodcommon.data.remote.api2.parser.PlayInfoJson2MediaSourceParser;
import com.google.gson.annotations.SerializedName;

import org.json.JSONException;

import java.util.Date;


public class VideoDetail {
    @SerializedName("vid")
    public String vid;
    @SerializedName("caption")
    public String caption;
    @SerializedName("duration")
    public double duration;
    @SerializedName("coverUrl")
    public String coverUrl;
    @SerializedName("videoModel")
    public String videoModel;
    @SerializedName("playAuthToken")
    public String playAuthToken;
    @SerializedName("subtitleAuthToken")
    public String subtitleAuthToken; // unused for now

    @SerializedName("subtitle")
    public String subtitle;

    @SerializedName("playTimes")
    public int playCount;

    @SerializedName("createTime")
    public Date createTime;

    @SerializedName("width")
    public int width;
    @SerializedName("height")
    public int height;

    @SerializedName("name")
    public String userName;
    @SerializedName("uid")
    public String userId;
    @SerializedName("like")
    public int likeCount;
    @SerializedName("comment")
    public int commentCount;

    @Nullable
    public static VideoItem toVideoItem(VideoDetail detail, int sourceType) {
        if (detail.playAuthToken != null) {
            // vid + playAuthToken
            VideoItem item = VideoItem.createVidItem(
                    detail.vid,
                    detail.playAuthToken,
                    detail.subtitleAuthToken,
                    (long) (detail.duration * 1000),
                    detail.coverUrl,
                    detail.caption);
            fillVideoItem(item, detail);
            return item;
        } else if (detail.videoModel != null) {
            switch (sourceType) {
                case VideoSettings.SourceType.SOURCE_TYPE_MODEL: {
                    VideoItem videoItem = VideoItem.createVideoModelItem(
                            detail.vid,
                            detail.videoModel,
                            detail.subtitleAuthToken,
                            (long) (detail.duration * 1000),
                            detail.coverUrl,
                            detail.caption);
                    VideoItem.toMediaSource(videoItem);
                    fillVideoItem(videoItem, detail);
                    return videoItem;
                }
                case VideoSettings.SourceType.SOURCE_TYPE_URL: {
                    MediaSource source = null;
                    try {
                        // Demonstrate parse VideoModel JSON to MediaSource object
                        // You should implement your own Parser with your AppServer data structure.
                        source = new PlayInfoJson2MediaSourceParser(detail.videoModel).parse();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    if (source == null) return null;
                    VideoItem item = VideoItem.createMultiStreamUrlItem(
                            detail.vid,
                            source,
                            (long) (detail.duration * 1000),
                            detail.coverUrl,
                            detail.caption);
                    fillVideoItem(item, detail);
                    return item;
                }
            }
        }
        return null;
    }

    @Nullable
    public static VideoItem toVideoItem(VideoDetail detail) {
        final int sourceType = VideoSettings.intValue(VideoSettings.COMMON_SOURCE_TYPE);
        return toVideoItem(detail, sourceType);
    }

    static void fillVideoItem(VideoItem item, VideoDetail detail) {
        item.setSubtitle(detail.subtitle);
        item.setPlayCount(detail.playCount);
        item.setCreateTime(detail.createTime);
        item.setSize(detail.width, detail.height);
        item.setUser(detail.userId, detail.userName);
        item.setLikeCount(detail.likeCount);
        item.setCommentCount(detail.commentCount);
    }
}
