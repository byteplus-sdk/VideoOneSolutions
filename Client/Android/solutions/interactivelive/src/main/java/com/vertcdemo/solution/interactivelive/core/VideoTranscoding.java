// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCEngine;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.live.MixedStreamConfig;
import com.ss.bytertc.engine.live.MixedStreamLayoutRegionConfig;
import com.ss.bytertc.engine.live.MixedStreamMediaType;
import com.ss.bytertc.engine.live.MixedStreamPushTargetConfig;
import com.ss.bytertc.engine.live.MixedStreamPushTargetType;
import com.ss.bytertc.engine.live.MixedStreamRenderMode;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;


import java.util.ArrayList;
import java.util.List;

public abstract class VideoTranscoding {

    private static final String TAG = "VideoTranscoding";
    private static final String MIXED_STREAM_TASK_ID = "interactive_live_mixed_stream";

    public static final String KEY_LIVE_MODE = "liveMode";

    @Nullable
    protected RTCEngine mRTCVideo;

    protected abstract LiveSettingConfig getLiveConfig();
    // Save the information of the current anchor user
    protected LiveInfoHost mMyLiveInfo;
    // Save the information of remote anchor
    protected LiveInfoHost mCoHostInfo;
    // params of live transcoding
    protected MixedStreamConfig mMixedStreamConfig = null;

    private boolean mIsRTCTranscoding = false;
    // whether is transcoding
    protected boolean isTranscoding() {
        return mIsRTCTranscoding;
    }
    // whether is pk with other anchor
    protected boolean isInPK() {
        return mCoHostInfo != null;
    }
    protected int mCoHostVideoWidth;
    protected int mCoHostVideoHeight;


    private List<String> mAudienceUserIdList;
    // local camera status
    private boolean mIsCameraOn = true;
    // local microphone status
    private boolean mIsMicOn = true;

    public boolean isCameraOn() {
        return mIsCameraOn;
    }

    protected void setCameraOn(boolean value) {
        mIsCameraOn = value;
    }

    public boolean isMicOn() {
        return mIsMicOn;
    }

    protected void setMicOn(boolean value) {
        mIsMicOn = value;
    }

    /**
     * Set the host video resolution of the other anchor
     *
     * @param coHostVideoWidth  The width of the host's video
     * @param coHostVideoHeight The height of the host's video
     */
    protected void setCoHostVideoConfig(int coHostVideoWidth, int coHostVideoHeight) {
        mCoHostVideoWidth = coHostVideoWidth;
        mCoHostVideoHeight = coHostVideoHeight;
    }

    protected void setLiveInfo(@NonNull LiveInfoHost info) {
        mMyLiveInfo = info;
    }

    protected void setCoHostInfo(LiveInfoHost coHostInfo) {
        mCoHostInfo = coHostInfo;
    }

    /**
     * Turn on live transcoding
     *
     * @param roomId room id
     * @param userId user id
     */
    protected void startLiveTranscoding(String roomId, String userId) {
        if (mMyLiveInfo == null) {
            Log.d(TAG, "You're not a host, no need to startLiveTranscoding.[SKIP]");
            return;
        }
        assert mMyLiveInfo.match(roomId, userId) : "LiveInfo mismatch!";
        Log.d(TAG, "startLiveTranscoding: " + mMyLiveInfo);
        startSingleLiveTranscoding();
    }

    /**
     * stop live transcoding
     */
    protected void stopLiveTranscoding() {
        Log.d(TAG, "stopLiveTranscoding");
        if (mIsRTCTranscoding && mRTCVideo != null) {
            stopRTCTranscoding();
        }

        mCoHostInfo = null;
        mMyLiveInfo = null;
        mMixedStreamConfig = null;
    }

    protected void updateLiveTranscodingWithHost(String coHostUserId) {
        adjustResolutionWhenPK(true, mCoHostVideoWidth, mCoHostVideoHeight);

        mMixedStreamConfig = createPK1v1LiveTranscodingConfig(coHostUserId);

        startOrUpdateRTCTranscoding(mMixedStreamConfig);
    }

    protected void stopLiveTranscodingWithHost() {
        mCoHostInfo = null;
        adjustResolutionWhenPK(false, mCoHostVideoWidth, mCoHostVideoHeight);
        startSingleLiveTranscoding();
    }

    /**
     * Adjust the encoding resolution during PK, and adjust it to half of the live broadcast alone
     *
     * @param adjust true means adjustment, false means recovery
     */
    protected void adjustResolutionWhenPK(boolean adjust, int coHostWidth, int coHostHeight) {
        if (mRTCVideo == null) {
            return;
        }
        LiveSettingConfig myConfig = getLiveConfig();
        VideoEncoderConfig config = new VideoEncoderConfig();
        config.frameRate = myConfig.frameRate;
        if (adjust) {
            config.width = (Math.max(myConfig.width, coHostWidth)) / 2;
            config.height = (Math.max(myConfig.height, coHostHeight)) / 2;
            config.maxBitrate = myConfig.bitRate / 4;
        } else {
            config.width = myConfig.width;
            config.height = myConfig.height;
            config.maxBitrate = myConfig.bitRate;
        }
        Log.d(TAG, "setVideoEncoderConfig: " + config);
        mRTCVideo.setVideoEncoderConfig(config);
    }

    /**
     * When mute the host of the other party, you need to modify the live transcoding parameters
     *
     * @param userId user userId
     * @param isMute whether it is mute
     */
    protected void updateLiveTranscodingWhenMuteCoHost(String userId, boolean isMute) {
        if (TextUtils.isEmpty(userId)) {
            Log.d(TAG, "muteCoHost() failed, userId is empty");
            return;
        }
        if (mMixedStreamConfig == null || mCoHostInfo == null) {
            Log.d(TAG, "muteCoHost() failed, LiveTranscoding params error");
            return;
        }
        MixedStreamLayoutRegionConfig[] regions = mMixedStreamConfig.regions;
        if (regions == null) {
            Log.d(TAG, "muteCoHost() failed, regions is null");
            return;
        }
        for (MixedStreamLayoutRegionConfig region : regions) {
            if (region != null && !region.isLocalUser && TextUtils.equals(userId, mCoHostInfo.userId)) {
                region.mediaType = isMute
                        ? MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_VIDEO_ONLY
                        : MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
                break;
            }
        }
        if (mRTCVideo != null) {
            startOrUpdateRTCTranscoding(mMixedStreamConfig);
        }
    }

    /**
     * Update the layout of the audience's params
     *
     * @param audienceIds audience id list, passing empty means end sharing
     */
    protected void updateLiveTranscodingWithAudience(List<String> audienceIds) {
        mAudienceUserIdList = audienceIds;

        if (audienceIds.size() == 0) {
            startSingleLiveTranscoding();
            return;
        }

        if (audienceIds.size() == 1) {
            startOrUpdateRTCTranscoding(createLink1v1LiveTranscodingConfig(audienceIds));
        } else {
            startOrUpdateRTCTranscoding(createLink1vNLiveTranscodingConfig(audienceIds));
        }
    }    protected void handleUserPublishStream(String uid, MediaStreamType type) {
        if (!isTranscoding()) {
            return;
        }
        // When the anchor connects with the anchor,
        // it is necessary to update the live transcoding parameters
        if (mCoHostInfo != null && TextUtils.equals(uid, mCoHostInfo.userId)) {
            updateLiveTranscodingWithHost(mCoHostInfo.userId);
        } else {
            updateLiveTranscodingWithAudience(mAudienceUserIdList);
        }
    }

    // region Create LiveTranscoding configurations

    private MixedStreamConfig createSingleLiveTranscodingConfig() {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig();

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.roomID = roomId;
        streamConfig.userID = userId;
        streamConfig.userConfigExtraInfo = appData(LiveMode.NORMAL);

        if (streamConfig.videoConfig != null) {
            streamConfig.videoConfig.width = videoWidth;
            streamConfig.videoConfig.height = videoHeight;
            streamConfig.videoConfig.fps = myConfig.frameRate;
            streamConfig.videoConfig.bitrate = myConfig.bitRate;
        }
        if (streamConfig.audioConfig != null) {
            streamConfig.audioConfig.sampleRate = 44100;
            streamConfig.audioConfig.channels = 2;
        }

        final MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig();
        region.userID = userId;
        region.roomID = roomId;
        region.isLocalUser = true;
        region.locationX = 0;
        region.locationY = 0;
        region.width = videoWidth;
        region.height = videoHeight;
        region.alpha = 1;
        region.zOrder = 0;
        region.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
        region.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;

        streamConfig.regions = new MixedStreamLayoutRegionConfig[]{region};

        return streamConfig;
    }


    private MixedStreamConfig createPK1v1LiveTranscodingConfig(String coHostUserId) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig();

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.roomID = roomId;
        streamConfig.userID = userId;
        streamConfig.userConfigExtraInfo = appData(LiveMode.LINK_PK);

        if (streamConfig.videoConfig != null) {
            streamConfig.videoConfig.width = videoWidth;
            streamConfig.videoConfig.height = videoHeight;
            streamConfig.videoConfig.fps = myConfig.frameRate;
            streamConfig.videoConfig.bitrate = myConfig.bitRate;
        }
        if (streamConfig.audioConfig != null) {
            streamConfig.audioConfig.sampleRate = 44100;
            streamConfig.audioConfig.channels = 2;
        }

        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig();
        selfRegion.userID = userId;
        selfRegion.roomID = roomId;
        selfRegion.isLocalUser = true;
        selfRegion.locationX = 0;
        selfRegion.locationY = (int) (videoWidth * 0.25);
        selfRegion.width = (int) (videoWidth * 0.5);
        selfRegion.height = (int) (videoHeight * 0.5);
        selfRegion.alpha = 1;
        selfRegion.zOrder = 0;
        selfRegion.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
        selfRegion.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;

        final MixedStreamLayoutRegionConfig hostRegion = new MixedStreamLayoutRegionConfig();
        hostRegion.userID = coHostUserId;
        hostRegion.roomID = roomId;
        hostRegion.isLocalUser = false;
        hostRegion.locationX = (int) (videoWidth * 0.5);
        hostRegion.locationY = (int) (videoHeight * 0.25);
        hostRegion.width = (int) (videoWidth * 0.5);
        hostRegion.height = (int) (videoHeight * 0.5);
        hostRegion.alpha = 1;
        hostRegion.zOrder = 0;
        hostRegion.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
        hostRegion.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;

        streamConfig.regions = new MixedStreamLayoutRegionConfig[]{selfRegion, hostRegion};

        return streamConfig;
    }

    private MixedStreamConfig createLink1v1LiveTranscodingConfig(@Size(value = 1) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig();

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.roomID = roomId;
        streamConfig.userID = userId;
        streamConfig.userConfigExtraInfo = appData(LiveMode.LINK_1v1);

        if (streamConfig.videoConfig != null) {
            streamConfig.videoConfig.width = videoWidth;
            streamConfig.videoConfig.height = videoHeight;
            streamConfig.videoConfig.fps = myConfig.frameRate;
            streamConfig.videoConfig.bitrate = myConfig.bitRate;
        }
        if (streamConfig.audioConfig != null) {
            streamConfig.audioConfig.sampleRate = 44100;
            streamConfig.audioConfig.channels = 2;
        }

        final List<MixedStreamLayoutRegionConfig> regions = new ArrayList<>();

        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig();
        selfRegion.userID = userId;
        selfRegion.roomID = roomId;
        selfRegion.isLocalUser = true;
        selfRegion.locationX = 0;
        selfRegion.locationY = 0;
        selfRegion.width = videoWidth;
        selfRegion.height = videoHeight;
        selfRegion.alpha = 1;
        selfRegion.zOrder = 0;
        selfRegion.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
        selfRegion.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;
        regions.add(selfRegion);

        final double screenWidth = 365;
        final double screenHeight = 667;
        final double itemSize = 120;
        final double itemSpace = 6;
        final double itemRightSpace = 24;
        final double itemBottomSpace = 52;
        final double itemCornerRadius = 2;

        final double cornerRadius = itemCornerRadius / itemSize;

        for (int index = 0, count = audienceIds.size(); index < count; index++) {
            double regionHeight = itemSize / screenHeight;
            double regionWidth = itemSize / screenWidth;
            double regionY = 1 - (itemBottomSpace + itemSize * (index + 1) + itemSpace * index) / screenHeight;
            double regionX = 1 - (regionHeight * screenHeight + itemRightSpace) / screenWidth;

            MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig();
            region.userID = audienceIds.get(index);
            region.roomID = roomId;
            region.locationX = (int) (videoWidth * regionX);
            region.locationY = (int) (videoHeight * regionY);
            region.width = (int) (videoWidth * regionWidth);
            region.height = (int) (videoHeight * regionHeight);
            region.cornerRadius = cornerRadius;
            region.alpha = 1;
            region.zOrder = 1;
            region.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
            region.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;
            regions.add(region);
        }

        streamConfig.regions = regions.toArray(new MixedStreamLayoutRegionConfig[0]);

        return streamConfig;
    }

    private MixedStreamConfig createLink1vNLiveTranscodingConfig(@Size(min = 2) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig();

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.roomID = roomId;
        streamConfig.userID = userId;
        streamConfig.userConfigExtraInfo = appData(LiveMode.LINK_1vN);
        streamConfig.backgroundColor = "#0D0B53";

        if (streamConfig.videoConfig != null) {
            streamConfig.videoConfig.width = videoWidth;
            streamConfig.videoConfig.height = videoHeight;
            streamConfig.videoConfig.fps = myConfig.frameRate;
            streamConfig.videoConfig.bitrate = myConfig.bitRate;
        }
        if (streamConfig.audioConfig != null) {
            streamConfig.audioConfig.sampleRate = 44100;
            streamConfig.audioConfig.channels = 2;
        }

        final int edgePixels = 4;

        final int itemHeightPixels = (videoHeight - edgePixels * 5) / 6; // floor
        final int itemWidthPixels = itemHeightPixels;

        final List<MixedStreamLayoutRegionConfig> regions = new ArrayList<>();
        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig();
        selfRegion.userID = userId;
        selfRegion.roomID = roomId;
        selfRegion.isLocalUser = true;
        selfRegion.locationX = 0;
        selfRegion.locationY = 0;
        selfRegion.width = videoWidth - itemWidthPixels - edgePixels;
        selfRegion.height = videoHeight;
        selfRegion.alpha = 1;
        selfRegion.zOrder = 0;
        selfRegion.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
        selfRegion.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;
        regions.add(selfRegion);

        final double itemWidth = (double) itemWidthPixels / videoWidth;
        final double itemHeight = (double) itemHeightPixels / videoHeight;

        final double itemX = 1.0 - itemWidth;

        final double edgeHeight = (double) edgePixels / videoHeight;

        for (int index = 0; index < audienceIds.size(); index++) {
            MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig();
            region.userID = audienceIds.get(index);
            region.roomID = roomId;
            region.locationX = (int) (videoWidth * itemX);
            region.locationY = (int) (videoHeight * (itemHeight + edgeHeight) * index);
            region.width = (int) (videoWidth * itemWidth);
            region.height = (int) (videoHeight * itemHeight);
            region.alpha = 1;
            region.zOrder = 1;
            region.mediaType = MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO;
            region.renderMode = MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN;
            regions.add(region);
        }

        streamConfig.regions = regions.toArray(new MixedStreamLayoutRegionConfig[0]);

        return streamConfig;
    }
    // endregion

    private void startSingleLiveTranscoding() {
        MixedStreamConfig mixedStreamConfig = createSingleLiveTranscodingConfig();
        startOrUpdateRTCTranscoding(mixedStreamConfig);
    }

    private void startOrUpdateRTCTranscoding(MixedStreamConfig mixedConfig) {
        if (mRTCVideo == null || mMyLiveInfo == null) {
            return;
        }

        MixedStreamPushTargetConfig target = new MixedStreamPushTargetConfig();
        target.pushTargetType = MixedStreamPushTargetType.PUSH_TO_CDN;
        target.pushCDNURL = mMyLiveInfo.pushUrl;

        if (mIsRTCTranscoding) {
            mRTCVideo.updatePushMixedStream(MIXED_STREAM_TASK_ID, target, mixedConfig);
        } else {
            mIsRTCTranscoding = true;
            mRTCVideo.startPushMixedStream(MIXED_STREAM_TASK_ID, target, mixedConfig);
        }
    }

    private void stopRTCTranscoding() {
        mIsRTCTranscoding = false;
        if (mRTCVideo != null) {
            mRTCVideo.stopPushMixedStream(MIXED_STREAM_TASK_ID, MixedStreamPushTargetType.PUSH_TO_CDN);
        }
    }

    private static String appData(@LiveMode int liveMode) {
        JsonObject json = new JsonObject();
        json.addProperty(KEY_LIVE_MODE, liveMode);
        return json.toString();
    }
}
