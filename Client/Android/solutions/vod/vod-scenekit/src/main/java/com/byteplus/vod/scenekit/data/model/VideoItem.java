// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.data.model;


import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.volcengine.Mapper;
import com.byteplus.playerkit.player.volcengine.VolcConfig;
import com.byteplus.playerkit.utils.ExtraObject;
import com.byteplus.playerkit.utils.MD5;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.strategy.VideoQuality;
import com.byteplus.vod.scenekit.strategy.VideoSubtitle;
import com.byteplus.vod.settingskit.Option;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class VideoItem extends ExtraObject implements ViewItem, Serializable {
    public static final String EXTRA_VIDEO_ITEM = "extra_video_item";

    public static final String PLAY_AUTH_TOKEN_NULL = "beb41110-b664-44f5-b9e7-05018684ca17";
    public static final String PLAY_AUTH_TOKEN_EMPTY = "2620463e-cbd6-4789-8da8-029e90c32b54";

    public static final int SOURCE_TYPE_EMPTY = -1;
    public static final int SOURCE_TYPE_VID = 0;
    public static final int SOURCE_TYPE_URL = 1;
    public static final int SOURCE_TYPE_MODEL = 2;

    private VideoItem() {
    }

    @Override
    public int itemType() {
        return ItemType.ITEM_TYPE_VIDEO;
    }

    // region Creators
    public static VideoItem createEmptyItem(@NonNull String vid,
                                            long duration,
                                            @Nullable String cover,
                                            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_EMPTY;
        videoItem.vid = vid;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }

    public static VideoItem createVidItem(
            @NonNull String vid,
            @NonNull String playAuthToken,
            @Nullable String cover) {
        return createVidItem(vid, playAuthToken, null, 0, cover, null);
    }

    public static VideoItem createVidItem(
            @NonNull String vid,
            @NonNull String playAuthToken,
            @Nullable String subtitleAuthToken,
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_VID;
        videoItem.vid = vid;
        videoItem.playAuthToken = playAuthToken;
        videoItem.subtitleAuthToken = subtitleAuthToken;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }

    public static VideoItem createUrlItem(@NonNull String url, @Nullable String cover) {
        return createUrlItem(MD5.getMD5(url), url, cover);
    }

    public static VideoItem createUrlItem(@NonNull String vid, @NonNull String url, @Nullable String cover) {
        return createUrlItem(vid, url, null, null, 0, cover, null);
    }

    public static VideoItem createUrlItem(
            @NonNull String vid,
            @NonNull String url,
            @Nullable String urlCacheKey,
            @Nullable List<Subtitle> subtitles,
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_URL;
        videoItem.vid = vid;
        videoItem.url = url;
        videoItem.urlCacheKey = urlCacheKey;
        videoItem.subtitles = subtitles;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }

    public static VideoItem createMultiStreamUrlItem(
            @NonNull String vid,
            @NonNull MediaSource mediaSource,
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_URL;
        videoItem.vid = vid;
        videoItem.mediaSource = mediaSource;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }

    public static VideoItem createVideoModelItem(
            @NonNull String vid,
            @NonNull String videoModel,
            @Nullable String subtitleAuthToken,
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_MODEL;
        videoItem.vid = vid;
        videoItem.videoModel = videoModel;
        videoItem.subtitleAuthToken = subtitleAuthToken;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }
// endregion

    private String vid;

    private String playAuthToken;

    private String subtitleAuthToken;

    private String videoModel;

    private MediaSource mediaSource;

    private long duration;

    private String title;

    private String cover;

    private String url;

    private String urlCacheKey;

    private List<Subtitle> subtitles;

    private int sourceType;

    private String tag;

    private String subTag;

    private int playScene;

    private boolean syncProgress;

    // region VideoOne Enhancement
    private String subtitle;
    private int playCount;

    private Date createTime;

    private int width;

    private int height;

    private String userName;
    private String userId;
    private int likeCount;
    private int commentCount;

    private boolean iLikeIt = false;
    // endregion

    public static String dump(VideoItem videoItem) {
        if (videoItem == null) return "VideoItem{ null }";
        return switch (videoItem.sourceType) {
            case SOURCE_TYPE_VID -> "VideoItem{ vid:" + videoItem.vid + "}";
            case SOURCE_TYPE_URL -> "VideoItem{ url:" + videoItem.url + "}";
            case SOURCE_TYPE_MODEL -> "VideoItem{ model:" + videoItem.videoModel + "}";
            case SOURCE_TYPE_EMPTY -> "VideoItem{ empty:" + videoItem.vid + "}";
            default -> "VideoItem{ sourceType:" + videoItem.sourceType + "}";
        };
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setPlayCount(int playCount) {
        this.playCount = playCount;
    }

    public int getPlayCount() {
        return playCount;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setSize(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public int getWidth() {
        return width;
    }

    public int getHeight() {
        return height;
    }

    public void setUser(String userId, String username) {
        this.userId = userId;
        this.userName = username;
    }

    public void setLikeCount(int count) {
        likeCount = count;
    }

    public void setILikeIt(boolean value) {
        iLikeIt = value;
    }

    public boolean isILikeIt() {
        return iLikeIt;
    }

    public void setCommentCount(int count) {
        commentCount = count;
    }

    public String getUserName() {
        return userName;
    }

    public String getUserId() {
        return userId;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public String getVid() {
        return vid;
    }

    @Deprecated
    public void setVid(String vid) {
        this.vid = vid;
    }

    public String getPlayAuthToken() {
        return playAuthToken;
    }

    public boolean playable() {
        if (sourceType == VideoItem.SOURCE_TYPE_VID) {
            return !TextUtils.isEmpty(vid) && !TextUtils.isEmpty(playAuthToken);
        } else if (sourceType == VideoItem.SOURCE_TYPE_URL) {
            return !TextUtils.isEmpty(url);
        } else if (sourceType == VideoItem.SOURCE_TYPE_MODEL) {
            return !TextUtils.isEmpty(videoModel);
        } else {
            return sourceType == VideoItem.SOURCE_TYPE_EMPTY;
        }
    }

    public String getVideoModel() {
        return videoModel;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCover() {
        return cover;
    }

    public String getUrl() {
        return url;
    }

    public String getUrlCacheKey() {
        return urlCacheKey;
    }

    public int getSourceType() {
        return sourceType;
    }

    public int getPlayScene() {
        return playScene;
    }

    public void updatePlayAuthToken(String authToken) {
        this.playAuthToken = authToken;
        if (mediaSource != null) {
            mediaSource.setPlayAuthToken(authToken);
        }
    }

    public void updateSubtitleAuthToken(String authToken) {
        this.subtitleAuthToken = authToken;
        if (mediaSource != null) {
            mediaSource.setSubtitleAuthToken(authToken);
        }
    }

    @NonNull
    public static MediaSource toMediaSource(VideoItem videoItem) {
        if (videoItem.mediaSource == null) {
            videoItem.mediaSource = createMediaSource(videoItem);
        }
        final MediaSource mediaSource = videoItem.mediaSource;
        VideoItem.set(mediaSource, videoItem);
        VolcConfig.set(mediaSource, createVolcConfig(videoItem));
        if (videoItem.syncProgress) {
            mediaSource.setSyncProgressId(videoItem.vid); // continues play
        }
        return mediaSource;
    }

    private static MediaSource createMediaSource(VideoItem videoItem) {
        if (videoItem.sourceType == VideoItem.SOURCE_TYPE_EMPTY) {
            MediaSource mediaSource = MediaSource.createIdSource(videoItem.vid, PLAY_AUTH_TOKEN_EMPTY);
            return mediaSource;
        } else if (videoItem.sourceType == VideoItem.SOURCE_TYPE_VID) {
            String playAuthToken = TextUtils.isEmpty(videoItem.playAuthToken) ? PLAY_AUTH_TOKEN_EMPTY : videoItem.playAuthToken;
            MediaSource mediaSource = MediaSource.createIdSource(videoItem.vid, playAuthToken);
            mediaSource.setSubtitleAuthToken(videoItem.subtitleAuthToken);
            return mediaSource;
        } else if (videoItem.sourceType == VideoItem.SOURCE_TYPE_URL) {
            MediaSource mediaSource = MediaSource.createUrlSource(videoItem.vid, videoItem.url, videoItem.urlCacheKey);
            mediaSource.setSubtitles(videoItem.subtitles);
            return mediaSource;
        } else if (videoItem.sourceType == VideoItem.SOURCE_TYPE_MODEL) {
            MediaSource mediaSource = MediaSource.createModelSource(videoItem.vid, videoItem.videoModel);
            Mapper.updateVideoModelMediaSource(mediaSource);
            mediaSource.setSubtitleAuthToken(videoItem.subtitleAuthToken);
            return mediaSource;
        } else {
            throw new IllegalArgumentException("unsupported source type! " + videoItem.sourceType);
        }
    }

    @NonNull
    public static VolcConfig createVolcConfig(VideoItem videoItem) {
        VolcConfig volcConfig = new VolcConfig();
        volcConfig.codecStrategyType = VideoSettings.intValue(VideoSettings.COMMON_CODEC_STRATEGY);
        volcConfig.playerDecoderType = VideoSettings.intValue(VideoSettings.COMMON_HARDWARE_DECODE);
        volcConfig.sourceEncodeType = VideoSettings.booleanValue(VideoSettings.COMMON_SOURCE_ENCODE_TYPE_H265) ? Track.ENCODER_TYPE_H265 : Track.ENCODER_TYPE_H264;
        volcConfig.enableSubtitle = true;
        volcConfig.qualityConfig = VideoQuality.sceneGearConfig(videoItem.playScene);

        volcConfig.tag = videoItem.tag;
        volcConfig.subTag = videoItem.subTag;
        return volcConfig;
    }

    @NonNull
    public static MediaSource toMediaSource(VideoItem videoItem, boolean syncProgress) {
        final MediaSource mediaSource = toMediaSource(videoItem);
        if (syncProgress) {
            mediaSource.setSyncProgressId(videoItem.vid); // continues play
        }
        return mediaSource;
    }

    public static List<MediaSource> toMediaSources(List<VideoItem> videoItems) {
        if (videoItems == null || videoItems.isEmpty()) {
            return Collections.emptyList();
        }
        List<MediaSource> sources = new ArrayList<>();
        for (VideoItem videoItem : videoItems) {
            sources.add(toMediaSource(videoItem));
        }
        return sources;
    }

    public static List<MediaSource> toMediaSources(List<VideoItem> videoItems, boolean syncProgress) {
        if (videoItems == null || videoItems.isEmpty()) {
            return Collections.emptyList();
        }
        List<MediaSource> sources = new ArrayList<>();
        for (VideoItem videoItem : videoItems) {
            sources.add(toMediaSource(videoItem, syncProgress));
        }
        return sources;
    }

    public static void set(MediaSource mediaSource, VideoItem videoItem) {
        if (mediaSource == null) return;

        if (!TextUtils.isEmpty(videoItem.cover)) {
            mediaSource.setCoverUrl(videoItem.cover);
        }
        if (videoItem.duration > 0) {
            mediaSource.setDuration(videoItem.duration);
        }
        mediaSource.putExtra(EXTRA_VIDEO_ITEM, videoItem);
    }

    @Nullable
    public static VideoItem get(MediaSource mediaSource) {
        if (mediaSource == null) return null;
        return mediaSource.getExtra(VideoItem.EXTRA_VIDEO_ITEM, VideoItem.class);
    }

    public static void tag(VideoItem videoItem, String tag, String subTag) {
        if (videoItem == null) return;
        videoItem.tag = tag;
        videoItem.subTag = subTag;
    }

    public static void tag(List<VideoItem> videoItems, String tag, String subTag) {
        for (VideoItem videoItem : videoItems) {
            tag(videoItem, tag, subTag);
        }
    }

    public static void tag(List<VideoItem> videoItems, String tag) {
        tag(videoItems, tag, null);
    }

    public static void playScene(List<VideoItem> videoItems, int playScene) {
        for (VideoItem videoItem : videoItems) {
            playScene(videoItem, playScene);
        }
    }

    public static void playScene(VideoItem videoItem, int playScene) {
        if (videoItem == null) return;
        videoItem.playScene = playScene;
    }


    public static boolean itemEquals(VideoItem item1, VideoItem item2) {
        if (item1 == item2) return true;
        if (item1 == null || item2 == null) return false;
        return TextUtils.equals(item1.vid, item2.vid);
    }

    public static void syncProgress(List<VideoItem> videoItems, boolean syncProgress) {
        if (videoItems == null) return;
        for (VideoItem videoItem : videoItems) {
            syncProgress(videoItem, syncProgress);
        }
    }

    public static void syncProgress(VideoItem videoItem, boolean syncProgress) {
        if (videoItem == null) return;
        videoItem.syncProgress = syncProgress;
    }
}
