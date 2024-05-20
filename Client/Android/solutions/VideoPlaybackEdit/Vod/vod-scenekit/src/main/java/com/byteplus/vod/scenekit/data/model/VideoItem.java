// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.data.model;

import static com.byteplus.playerkit.player.ve.PlayerConfig.EXTRA_VE_CONFIG;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.ve.Mapper;
import com.byteplus.playerkit.player.ve.PlayerConfig;
import com.byteplus.playerkit.utils.MD5;
import com.byteplus.vod.scenekit.VideoSettings;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class VideoItem implements Parcelable {
    public static final String EXTRA_VIDEO_ITEM = "extra_video_item";

    public static final int SOURCE_TYPE_VID = 0;
    public static final int SOURCE_TYPE_URL = 1;
    public static final int SOURCE_TYPE_MODEL = 2;

    private VideoItem() {
    }

    protected VideoItem(Parcel in) {
        vid = in.readString();
        playAuthToken = in.readString();
        videoModel = in.readString();
        mediaSource = (MediaSource) in.readSerializable();
        duration = in.readLong();
        title = in.readString();
        cover = in.readString();
        url = in.readString();
        urlCacheKey = in.readString();
        sourceType = in.readInt();
        tag = in.readString();
        subTag = in.readString();
        subtitle = in.readString();
        playCount = in.readInt();
        createTime = (Date) in.readSerializable();
        width = in.readInt();
        height = in.readInt();
        userName = in.readString();
        userId = in.readString();
        likeCount = in.readInt();
        commentCount = in.readInt();
        playScene = in.readInt();
        subtitleAuthToken = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(vid);
        dest.writeString(playAuthToken);
        dest.writeString(videoModel);
        dest.writeSerializable(mediaSource);
        dest.writeLong(duration);
        dest.writeString(title);
        dest.writeString(cover);
        dest.writeString(url);
        dest.writeString(urlCacheKey);
        dest.writeInt(sourceType);
        dest.writeString(tag);
        dest.writeString(subTag);
        dest.writeString(subtitle);
        dest.writeInt(playCount);
        dest.writeSerializable(createTime);
        dest.writeInt(width);
        dest.writeInt(height);
        dest.writeString(userName);
        dest.writeString(userId);
        dest.writeInt(likeCount);
        dest.writeInt(commentCount);
        dest.writeInt(playScene);
        dest.writeString(subtitleAuthToken);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VideoItem> CREATOR = new Creator<VideoItem>() {
        @Override
        public VideoItem createFromParcel(Parcel in) {
            return new VideoItem(in);
        }

        @Override
        public VideoItem[] newArray(int size) {
            return new VideoItem[size];
        }
    };

    public static VideoItem createVidItem(
            @NonNull String vid,
            @NonNull String playAuthToken,
            @Nullable String cover) {
        return createVidItem(vid, playAuthToken, 0, cover, null, null);
    }

    public static VideoItem createVidItem(
            @NonNull String vid,
            @NonNull String playAuthToken,
            long duration,
            @Nullable String cover,
            @Nullable String title,
            @Nullable String subtitleAuthToken) {
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
        return createUrlItem(MD5.getMD5(url), url, null, 0, cover, null);
    }

    public static VideoItem createUrlItem(
            @NonNull String vid,
            @NonNull String url,
            @Nullable String urlCacheKey,
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        VideoItem videoItem = new VideoItem();
        videoItem.sourceType = SOURCE_TYPE_URL;
        videoItem.vid = vid;
        videoItem.url = url;
        videoItem.urlCacheKey = urlCacheKey;
        videoItem.duration = duration;
        videoItem.cover = cover;
        videoItem.title = title;
        return videoItem;
    }

    public static VideoItem createMultiStreamUrlItem(
            @Nullable String vid,
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
            long duration,
            @Nullable String cover,
            @Nullable String title) {
        return createVideoModelItem(vid, videoModel, "", duration,cover, title);
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

    private int sourceType;


    private String tag;

    private String subTag;

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

    private int playScene;

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

    public String getPlayAuthToken() {
        return playAuthToken;
    }

    public String getVideoModel() {
        return videoModel;
    }

    public long getDuration() {
        return duration;
    }

    public String getTitle() {
        return title;
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
    @NonNull
    public static MediaSource toMediaSource(VideoItem videoItem) {
        return toMediaSource(videoItem, false);
    }

    @NonNull
    public static MediaSource toMediaSource(VideoItem videoItem, boolean syncProgress) {
        final MediaSource mediaSource;
        if (videoItem.mediaSource != null) {
            mediaSource = videoItem.mediaSource;
        } else {
            if (videoItem.sourceType == VideoItem.SOURCE_TYPE_VID) {
                mediaSource = MediaSource.createIdSource(videoItem.vid, videoItem.playAuthToken, videoItem.subtitleAuthToken);
            } else if (videoItem.sourceType == VideoItem.SOURCE_TYPE_URL) {
                mediaSource = MediaSource.createUrlSource(videoItem.vid, videoItem.url, videoItem.urlCacheKey);
            } else if (videoItem.sourceType == VideoItem.SOURCE_TYPE_MODEL) {
                mediaSource = MediaSource.createModelSource(videoItem.vid, videoItem.videoModel);
                Mapper.updateVideoModelMediaSource(mediaSource);
            } else {
                throw new IllegalArgumentException("unsupported source type! " + videoItem.sourceType);
            }
        }
        if (!TextUtils.isEmpty(videoItem.cover)) {
            mediaSource.setCoverUrl(videoItem.cover);
        }
        mediaSource.setDuration(videoItem.duration);
        mediaSource.putExtra(EXTRA_VIDEO_ITEM, videoItem);
        mediaSource.putExtra(EXTRA_VE_CONFIG, createVEConfig(videoItem));
        if (syncProgress) {
            mediaSource.setSyncProgressId(videoItem.vid); // continues play
        }
        videoItem.mediaSource = mediaSource;
        return mediaSource;
    }

    public static List<MediaSource> toMediaSources(List<VideoItem> videoItems, boolean syncProgress) {
        List<MediaSource> sources = new ArrayList<>();
        if (videoItems != null) {
            for (VideoItem videoItem : videoItems) {
                sources.add(VideoItem.toMediaSource(videoItem, syncProgress));
            }
        }
        return sources;
    }

    @NonNull
    public static PlayerConfig createVEConfig(VideoItem videoItem) {
        PlayerConfig playerConfig = new PlayerConfig();
        playerConfig.codecStrategyType = VideoSettings.intValue(VideoSettings.COMMON_CODEC_STRATEGY);
        playerConfig.playerDecoderType = VideoSettings.intValue(VideoSettings.COMMON_HARDWARE_DECODE);
        playerConfig.sourceEncodeType = VideoSettings.booleanValue(VideoSettings.COMMON_SOURCE_ENCODE_TYPE_H265) ? Track.ENCODER_TYPE_H265 : Track.ENCODER_TYPE_H264;
        playerConfig.enableSuperResolution = VideoSettings.booleanValue(VideoSettings.COMMON_SUPER_RESOLUTION);
        playerConfig.tag = videoItem.tag;
        playerConfig.subTag = videoItem.subTag;
        return playerConfig;
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
}
