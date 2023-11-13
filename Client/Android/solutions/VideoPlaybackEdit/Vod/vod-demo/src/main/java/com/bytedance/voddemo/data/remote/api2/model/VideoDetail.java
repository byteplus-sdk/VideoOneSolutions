// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;

import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.voddemo.data.remote.api2.parser.PlayInfoJson2MediaSourceParser;
import com.google.gson.annotations.SerializedName;

import org.json.JSONException;

import java.util.Date;


public class VideoDetail {
    public String vid;
    public String caption;
    public double duration;
    public String coverUrl;
    public String videoModel;
    public String playAuthToken;

    public String subtitleAuthToken; // unused for now

    @SerializedName("subtitle")
    public String subtitle;

    @SerializedName("playTimes")
    public int playCount;

    @SerializedName("createTime")
    public Date createTime;

    @Nullable
    public static VideoItem toVideoItem(VideoDetail detail) {
        if (detail.playAuthToken != null) {
            // vid + playAuthToken
            VideoItem item = VideoItem.createVidItem(
                    detail.vid,
                    detail.playAuthToken,
                    (long) (detail.duration * 1000),
                    detail.coverUrl,
                    detail.caption);
            item.setSubtitle(detail.subtitle);
            item.setPlayCount(detail.playCount);
            item.setCreateTime(detail.createTime);
            return item;
        } else if (detail.videoModel != null) {
            final int sourceType = VideoSettings.intValue(VideoSettings.COMMON_SOURCE_TYPE);
            switch (sourceType) {
                case VideoSettings.SourceType.SOURCE_TYPE_MODEL: {
                    VideoItem videoItem = VideoItem.createVideoModelItem(
                            detail.vid,
                            detail.videoModel,
                            (long) (detail.duration * 1000),
                            detail.coverUrl,
                            detail.caption);
                    VideoItem.toMediaSource(videoItem, false);
                    videoItem.setSubtitle(detail.subtitle);
                    videoItem.setPlayCount(detail.playCount);
                    videoItem.setCreateTime(detail.createTime);
                    return videoItem;
                }
                case VideoSettings.SourceType.SOURCE_TYPE_URL: {
                    MediaSource source = null;
                    try {
                        // Demonstrate parse VideoModel JSON to MediaSource object
                        // You should implement your own Parser with your AppServer data structure.
                        source = new PlayInfoJson2MediaSourceParser().parse(detail.videoModel);
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
                    item.setSubtitle(detail.subtitle);
                    item.setPlayCount(detail.playCount);
                    item.setCreateTime(detail.createTime);
                    return item;
                }
            }
        }
        return null;
    }
}
