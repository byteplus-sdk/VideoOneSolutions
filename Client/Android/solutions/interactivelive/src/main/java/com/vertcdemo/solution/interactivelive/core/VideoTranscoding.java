// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.live.ByteRTCStreamMixingType;
import com.ss.bytertc.engine.live.MixedStreamConfig;
import com.ss.bytertc.engine.live.MixedStreamConfig.MixedStreamLayoutConfig;
import com.ss.bytertc.engine.live.MixedStreamConfig.MixedStreamLayoutRegionConfig;
import com.ss.bytertc.engine.live.MixedStreamConfig.MixedStreamMediaType;
import com.ss.bytertc.engine.live.MixedStreamConfig.MixedStreamRenderMode;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;
import com.vertcdemo.solution.interactivelive.core.live.LiveCoreHolder;

import java.util.ArrayList;
import java.util.List;

public abstract class VideoTranscoding {

    public enum PushMode {
        RTC,
        LIVE_CORE
    }

    public static final PushMode PUSH_MODE = PushMode.LIVE_CORE;

    private static final String TAG = "VideoTranscoding";

    public static final String KEY_LIVE_MODE = "liveMode";

    private static final ByteRTCStreamMixingType STREAM_MIXING_TYPE = ByteRTCStreamMixingType.STREAM_MIXING_BY_SERVER;

    @Nullable
    protected RTCVideo mRTCVideo;

    protected abstract LiveSettingConfig getLiveConfig();
    // Save the information of the current anchor user
    protected LiveInfoHost mMyLiveInfo;
    // Save the information of remote anchor
    protected LiveInfoHost mCoHostInfo;
    // params of live transcoding
    protected MixedStreamConfig mMixedStreamConfig = null;

    private boolean mIsLiveCoreTranscoding = false;

    private boolean mIsRTCTranscoding = false;
    // whether is transcoding
    protected boolean isTranscoding() {
        return mIsRTCTranscoding || mIsLiveCoreTranscoding;
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
        notifyCameraStatusChanged(value);
    }

    public boolean isMicOn() {
        return mIsMicOn;
    }

    protected void setMicOn(boolean value) {
        mIsMicOn = value;
        notifyMicrophoneStatusChanged(value);
    }

    @Nullable
    private LiveCoreHolder mHolder;

    @Nullable
    public LiveCoreHolder getLiveCore() {
        return mHolder;
    }

    protected void release() {
        releaseLiveCore();
    }

    protected void releaseLiveCore() {
        if (mHolder != null) {
            mHolder.release();
            mHolder = null;
        }
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

    private final MixedStreamObserverAdapter mMixedStreamObserver = new MixedStreamObserverAdapter();

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
        if (mIsLiveCoreTranscoding) {
            stopLiveCorePush();
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
        MixedStreamLayoutConfig layout = mMixedStreamConfig.getLayout();
        if (layout == null) {
            Log.d(TAG, "muteCoHost() failed, layout is null");
            return;
        }
        MixedStreamLayoutRegionConfig[] regions = layout.getRegions();
        if (regions == null) {
            Log.d(TAG, "muteCoHost() failed, regions is null");
            return;
        }
        for (MixedStreamLayoutRegionConfig region : regions) {
            if (region != null && !region.getIsLocalUser() && TextUtils.equals(userId, mCoHostInfo.userId)) {
                region.setMediaType(isMute
                        ? MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_VIDEO_ONLY
                        : MixedStreamMediaType.MIXED_STREAM_MEDIA_TYPE_AUDIO_AND_VIDEO);
                break;
            }
        }
        if (mRTCVideo != null) {
            mRTCVideo.updatePushMixedStreamToCDN("", mMixedStreamConfig);
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
    }

    protected void handleUserPublishStream(String uid, MediaStreamType type) {
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
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig()
                .setRoomID(roomId)
                .setPushURL(pushUrl)
                .setExpectedMixingType(STREAM_MIXING_TYPE);

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;
        streamConfig.getVideoConfig()
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setFps(myConfig.frameRate)
                .setBitrate(myConfig.bitRate);
        // Set the live transcoding audio parameters, the specific parameters depend on the situation
        streamConfig.getAudioConfig()
                .setSampleRate(44100)
                .setChannels(2);
        // Set live transcoding video layout parameters
        final MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig()
                .setUserID(userId)
                .setIsLocalUser(true)
                .setRoomID(roomId)
                .setLocationX(0)
                .setLocationY(0)
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setAlpha(1)
                .setZOrder(0)
                .setRenderMode(MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN);

        final MixedStreamLayoutConfig layout = new MixedStreamLayoutConfig()
                .setRegions(new MixedStreamLayoutRegionConfig[]{region})
                .setUserConfigExtraInfo(appData(LiveMode.NORMAL));
        streamConfig.setLayout(layout);

        return streamConfig;
    }


    private MixedStreamConfig createPK1v1LiveTranscodingConfig(String coHostUserId) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig()
                .setRoomID(roomId)
                .setPushURL(pushUrl)
                .setExpectedMixingType(STREAM_MIXING_TYPE);

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.getVideoConfig()
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setFps(myConfig.frameRate)
                .setBitrate(myConfig.bitRate);

        streamConfig.getAudioConfig()
                .setSampleRate(44100)
                .setChannels(2);

        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig()
                .setUserID(userId)
                .setIsLocalUser(true)
                .setRoomID(roomId)
                .setLocationX(0)
                .setLocationY((int) (videoWidth * 0.25))
                .setWidth((int) (videoWidth * 0.5))
                .setHeight((int) (videoHeight * 0.5))
                .setAlpha(1)
                .setZOrder(0)
                .setRenderMode(MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN);

        final MixedStreamLayoutRegionConfig hostRegion = new MixedStreamLayoutRegionConfig()
                .setUserID(coHostUserId)
                .setIsLocalUser(false)
                .setRoomID(roomId)
                .setLocationX((int) (videoWidth * 0.5))
                .setLocationY((int) (videoHeight * 0.25))
                .setWidth((int) (videoWidth * 0.5))
                .setHeight((int) (videoHeight * 0.5))
                .setAlpha(1)
                .setZOrder(0)
                .setRenderMode(MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN);

        final MixedStreamLayoutConfig layout = new MixedStreamLayoutConfig()
                .setRegions(new MixedStreamLayoutRegionConfig[]{selfRegion, hostRegion})
                .setUserConfigExtraInfo(appData(LiveMode.LINK_PK));
        streamConfig.setLayout(layout);

        return streamConfig;
    }

    private MixedStreamConfig createLink1v1LiveTranscodingConfig(@Size(value = 1) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig()
                .setRoomID(roomId)
                .setPushURL(pushUrl)
                .setExpectedMixingType(STREAM_MIXING_TYPE);

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.getVideoConfig()
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setFps(myConfig.frameRate)
                .setBitrate(myConfig.bitRate);

        streamConfig.getAudioConfig()
                .setSampleRate(44100)
                .setChannels(2);

        final List<MixedStreamLayoutRegionConfig> regions = new ArrayList<>();

        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig()
                .setUserID(userId)
                .setIsLocalUser(true)
                .setRoomID(roomId)
                .setLocationX(0)
                .setLocationY(0)
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setAlpha(1)
                .setZOrder(0);
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

            MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig()
                    .setUserID(audienceIds.get(index))
                    .setRoomID(roomId)
                    .setLocationX((int) (videoWidth * regionX))
                    .setLocationY((int) (videoHeight * regionY))
                    .setWidth((int) (videoWidth * regionWidth))
                    .setHeight((int) (videoHeight * regionHeight))
                    .setCornerRadius(cornerRadius)
                    .setAlpha(1)
                    .setZOrder(1);
            regions.add(region);
        }

        final MixedStreamLayoutConfig layout = new MixedStreamLayoutConfig()
                .setRegions(regions.toArray(new MixedStreamLayoutRegionConfig[0]))
                .setUserConfigExtraInfo(appData(LiveMode.LINK_1v1));
        streamConfig.setLayout(layout);

        return streamConfig;
    }

    private MixedStreamConfig createLink1vNLiveTranscodingConfig(@Size(min = 2) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        final MixedStreamConfig streamConfig = MixedStreamConfig.defaultMixedStreamConfig()
                .setRoomID(roomId)
                .setPushURL(pushUrl)
                .setExpectedMixingType(STREAM_MIXING_TYPE);

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        streamConfig.getVideoConfig()
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setFps(myConfig.frameRate)
                .setBitrate(myConfig.bitRate);

        streamConfig.getAudioConfig()
                .setSampleRate(44100)
                .setChannels(2);

        final int edgePixels = 4;

        final int itemHeightPixels = (videoHeight - edgePixels * 5) / 6; // floor
        final int itemWidthPixels = itemHeightPixels;

        final List<MixedStreamLayoutRegionConfig> regions = new ArrayList<>();
        final MixedStreamLayoutRegionConfig selfRegion = new MixedStreamLayoutRegionConfig()
                .setUserID(userId)
                .setIsLocalUser(true)
                .setRoomID(roomId)
                .setLocationX(0)
                .setLocationY(0)
                .setWidth(videoWidth - itemWidthPixels - edgePixels)
                .setHeight(videoHeight)
                .setAlpha(1)
                .setZOrder(0);
        regions.add(selfRegion);

        final double itemWidth = (double) itemWidthPixels / videoWidth;
        final double itemHeight = (double) itemHeightPixels / videoHeight;

        final double itemX = 1.0 - itemWidth;

        final double edgeHeight = (double) edgePixels / videoHeight;

        for (int index = 0; index < audienceIds.size(); index++) {
            MixedStreamLayoutRegionConfig region = new MixedStreamLayoutRegionConfig()
                    .setUserID(audienceIds.get(index))
                    .setRoomID(roomId)
                    .setLocationX((int) (videoWidth * itemX))
                    .setLocationY((int) (videoHeight * (itemHeight + edgeHeight) * index))
                    .setWidth((int) (videoWidth * itemWidth))
                    .setHeight((int) (videoHeight * itemHeight))
                    .setAlpha(1)
                    .setZOrder(1);
            regions.add(region);
        }

        final MixedStreamLayoutConfig layout = new MixedStreamLayoutConfig()
                .setRegions(regions.toArray(new MixedStreamLayoutRegionConfig[0]))
                .setUserConfigExtraInfo(appData(LiveMode.LINK_1vN))
                .setBackgroundColor("#0D0B53");
        streamConfig.setLayout(layout);

        return streamConfig;
    }
    // endregion

    private void startSingleLiveTranscoding() {
        if (PUSH_MODE == PushMode.RTC) {
            stopLiveCorePush();

            MixedStreamConfig mixedStreamConfig = createSingleLiveTranscodingConfig();
            startOrUpdateRTCTranscoding(mixedStreamConfig);
        } else {
            stopRTCTranscoding();

            startLiveCorePush();
        }
    }

    private void startOrUpdateRTCTranscoding(MixedStreamConfig mixedConfig) {
        if (mRTCVideo != null) {
            if (mIsRTCTranscoding) {
                mRTCVideo.updatePushMixedStreamToCDN("", mixedConfig);
            } else {
                if (PUSH_MODE == PushMode.LIVE_CORE) {
                    stopLiveCorePush();
                }

                mIsRTCTranscoding = true;
                mRTCVideo.startPushMixedStreamToCDN("", mixedConfig, mMixedStreamObserver);
            }
        }
    }

    private void stopRTCTranscoding() {
        mIsRTCTranscoding = false;
        if (mRTCVideo != null) {
            mRTCVideo.stopPushStreamToCDN("");
        }
    }

    private void startLiveCorePush() {
        if (PUSH_MODE != PushMode.LIVE_CORE) {
            return;
        }
        if (mHolder == null) {
            mHolder = LiveCoreHolder.createLiveCore(isCameraOn(), isMicOn());
        } else {
            if (isCameraOn()) {
                mHolder.stopFakeVideo();
            } else {
                mHolder.startFakeVideo();
            }
            if (isMicOn()) {
                mHolder.stopFakeAudio();
            } else {
                mHolder.startFakeAudio();
            }
        }
        mIsLiveCoreTranscoding = true;
        assert mMyLiveInfo != null;

        final LiveSettingConfig myConfig = getLiveConfig();
        int videoWidth = myConfig.width;
        int videoHeight = myConfig.height;

        mHolder.changeConfig(videoWidth,
                videoHeight,
                myConfig.frameRate,
                myConfig.bitRate); // RTC bitrate Kbps

        mHolder.start(mRTCVideo, mMyLiveInfo.pushUrl);
    }

    private void stopLiveCorePush() {
        if (PUSH_MODE != PushMode.LIVE_CORE) {
            return;
        }
        if (mHolder == null) {
            return;
        }
        mIsLiveCoreTranscoding = false;
        mHolder.stop(mRTCVideo);
    }

    private void notifyCameraStatusChanged(boolean value) {
        if (mIsLiveCoreTranscoding && mHolder != null) {
            if (value) {
                mHolder.stopFakeVideo();
            } else {
                mHolder.startFakeVideo();
            }
        }
    }

    private void notifyMicrophoneStatusChanged(boolean value) {
        if (mIsLiveCoreTranscoding && mHolder != null) {
            if (value) {
                mHolder.stopFakeAudio();
            } else {
                mHolder.startFakeAudio();
            }
        }
    }

    private static String appData(@LiveMode int liveMode) {
        JsonObject json = new JsonObject();
        json.addProperty(KEY_LIVE_MODE, liveMode);
        return json.toString();
    }
}
