// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;

import com.google.gson.JsonObject;
import com.ss.avframework.livestreamv2.core.LiveCore;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.live.ByteRTCStreamMixingType;
import com.ss.bytertc.engine.live.ILiveTranscodingObserver;
import com.ss.bytertc.engine.live.LiveTranscoding;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;
import com.vertcdemo.solution.interactivelive.core.live.LiveCoreHolder;

import java.util.List;

public abstract class VideoTranscoding {

    enum PushMode {
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
    protected LiveTranscoding mLiveTranscoding = null;

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
    public LiveCore getLiveCore() {
        return mHolder == null ? null : mHolder.getLiveCore();
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

    private final ILiveTranscodingObserver mILiveTranscodingObserver = new LiveTranscodingObserverAdapter();

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
        mLiveTranscoding = null;
    }

    protected void updateLiveTranscodingWithHost(String coHostUserId) {
        adjustResolutionWhenPK(true, mCoHostVideoWidth, mCoHostVideoHeight);

        mLiveTranscoding = createPK1v1LiveTranscodingConfig(coHostUserId);

        startOrUpdateRTCTranscoding(mLiveTranscoding);
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
        if (mLiveTranscoding == null || mCoHostInfo == null) {
            Log.d(TAG, "muteCoHost() failed, LiveTranscoding params error");
            return;
        }
        LiveTranscoding.Layout layout = mLiveTranscoding.getLayout();
        if (layout == null) {
            Log.d(TAG, "muteCoHost() failed, layout is null");
            return;
        }
        LiveTranscoding.Region[] regions = layout.getRegions();
        if (regions == null) {
            Log.d(TAG, "muteCoHost() failed, regions is null");
            return;
        }
        for (LiveTranscoding.Region region : regions) {
            if (region != null && !region.isLocalUser() && TextUtils.equals(userId, mCoHostInfo.userId)) {
                region.contentControl(isMute ?
                        LiveTranscoding.TranscoderContentControlType.HAS_VIDEO_ONLY :
                        LiveTranscoding.TranscoderContentControlType.HAS_AUDIO_AND_VIDEO);
                break;
            }
        }
        if (mRTCVideo != null) {
            mRTCVideo.updateLiveTranscoding("", mLiveTranscoding);
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
            LiveTranscoding liveTranscoding = createLink1v1LiveTranscodingConfig(audienceIds);
            startOrUpdateRTCTranscoding(liveTranscoding);
        } else {
            LiveTranscoding liveTranscoding = createLink1vNLiveTranscodingConfig(audienceIds);
            startOrUpdateRTCTranscoding(liveTranscoding);
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
    private LiveTranscoding createSingleLiveTranscodingConfig() {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        LiveTranscoding liveTranscoding = LiveTranscoding.getDefualtLiveTranscode();
        // set room id
        liveTranscoding.setRoomId(roomId);
        // Set the live address of push stream
        liveTranscoding.setUrl(pushUrl);
        // Set the merge mode, 0 means server merge
        liveTranscoding.setMixType(STREAM_MIXING_TYPE);
        LiveTranscoding.VideoConfig videoConfig = liveTranscoding.getVideo()
                .setWidth(myConfig.width)
                .setHeight(myConfig.height)
                .setFps(myConfig.frameRate)
                .setKBitRate(myConfig.bitRate);
        liveTranscoding.setVideo(videoConfig);
        // Set the live transcoding audio parameters, the specific parameters depend on the situation
        LiveTranscoding.AudioConfig audioConfig = liveTranscoding.getAudio()
                .setSampleRate(44100)
                .setChannels(2);
        liveTranscoding.setAudio(audioConfig);
        // Set live transcoding video layout parameters
        LiveTranscoding.Region region = new LiveTranscoding.Region()
                .uid(userId)
                .setLocalUser(true)
                .roomId(roomId)
                .position(0, 0)
                .size(1, 1)
                .alpha(1)
                .zorder(0)
                .renderMode(LiveTranscoding.TranscoderRenderMode.RENDER_HIDDEN);

        LiveTranscoding.Layout layout = new LiveTranscoding.Layout.Builder()
                .addRegion(region)
                .appData(appData(LiveMode.NORMAL))
                .builder();
        liveTranscoding.setLayout(layout);

        return liveTranscoding;
    }


    private LiveTranscoding createPK1v1LiveTranscodingConfig(String coHostUserId) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        LiveTranscoding liveTranscoding = LiveTranscoding.getDefualtLiveTranscode();
        liveTranscoding.setRoomId(roomId);
        liveTranscoding.setUrl(pushUrl);
        liveTranscoding.setMixType(STREAM_MIXING_TYPE);

        LiveTranscoding.VideoConfig videoConfig = liveTranscoding.getVideo()
                .setWidth(myConfig.width)
                .setHeight(myConfig.height)
                .setFps(myConfig.frameRate)
                .setKBitRate(myConfig.bitRate);
        liveTranscoding.setVideo(videoConfig);

        LiveTranscoding.AudioConfig audioConfig = liveTranscoding.getAudio()
                .setSampleRate(44100)
                .setChannels(2);
        liveTranscoding.setAudio(audioConfig);

        LiveTranscoding.Layout.Builder layoutBuilder = new LiveTranscoding.Layout.Builder();

        LiveTranscoding.Region selfRegion = new LiveTranscoding.Region()
                .uid(userId)
                .setLocalUser(true)
                .roomId(roomId)
                .position(0, 0.25)
                .size(0.5, 0.5)
                .alpha(1)
                .zorder(0);
        layoutBuilder.addRegion(selfRegion);

        LiveTranscoding.Region hostRegion = new LiveTranscoding.Region()
                .uid(coHostUserId)
                .roomId(roomId)
                .position(0.5, 0.25)
                .size(0.5, 0.5)
                .alpha(1)
                .zorder(0);
        layoutBuilder.addRegion(hostRegion);

        layoutBuilder.appData(appData(LiveMode.LINK_PK));
        liveTranscoding.setLayout(layoutBuilder.builder());
        return liveTranscoding;
    }

    private LiveTranscoding createLink1v1LiveTranscodingConfig(@Size(value = 1) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        LiveTranscoding liveTranscoding = LiveTranscoding.getDefualtLiveTranscode();
        liveTranscoding.setRoomId(roomId);
        liveTranscoding.setUrl(pushUrl);
        liveTranscoding.setMixType(STREAM_MIXING_TYPE);

        LiveTranscoding.VideoConfig videoConfig = liveTranscoding.getVideo()
                .setWidth(myConfig.width)
                .setHeight(myConfig.height)
                .setFps(myConfig.frameRate)
                .setKBitRate(myConfig.bitRate);
        liveTranscoding.setVideo(videoConfig);

        LiveTranscoding.AudioConfig audioConfig = liveTranscoding.getAudio()
                .setSampleRate(44100)
                .setChannels(2);
        liveTranscoding.setAudio(audioConfig);

        LiveTranscoding.Layout.Builder layoutBuilder = new LiveTranscoding.Layout.Builder();
        LiveTranscoding.Region selfRegion = new LiveTranscoding.Region()
                .uid(userId)
                .setLocalUser(true)
                .roomId(roomId)
                .position(0, 0)
                .size(1, 1)
                .alpha(1)
                .zorder(0);
        layoutBuilder.addRegion(selfRegion);

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

            LiveTranscoding.Region region = new LiveTranscoding.Region()
                    .uid(audienceIds.get(index))
                    .roomId(roomId)
                    .position(regionX, regionY)
                    .size(regionWidth, regionHeight)
//                    .setCornerRadius(cornerRadius)
                    .alpha(1)
                    .zorder(1);
            layoutBuilder.addRegion(region);
        }

        layoutBuilder.appData(appData(LiveMode.LINK_1v1));
        liveTranscoding.setLayout(layoutBuilder.builder());

        return liveTranscoding;
    }

    private LiveTranscoding createLink1vNLiveTranscodingConfig(@Size(min = 2) List<String> audienceIds) {
        final String userId = mMyLiveInfo.userId;
        final String roomId = mMyLiveInfo.roomId;
        final String pushUrl = mMyLiveInfo.pushUrl;
        final LiveSettingConfig myConfig = getLiveConfig();

        LiveTranscoding liveTranscoding = LiveTranscoding.getDefualtLiveTranscode();
        liveTranscoding.setRoomId(roomId);
        liveTranscoding.setUrl(pushUrl);
        liveTranscoding.setMixType(STREAM_MIXING_TYPE);

        final int videoWidth = myConfig.width;
        final int videoHeight = myConfig.height;

        LiveTranscoding.VideoConfig videoConfig = liveTranscoding.getVideo()
                .setWidth(videoWidth)
                .setHeight(videoHeight)
                .setFps(myConfig.frameRate)
                .setKBitRate(myConfig.bitRate);
        liveTranscoding.setVideo(videoConfig);

        LiveTranscoding.AudioConfig audioConfig = liveTranscoding.getAudio()
                .setSampleRate(44100)
                .setChannels(2);
        liveTranscoding.setAudio(audioConfig);

        final int edgePixels = 4;

        final int itemHeightPixels = (videoHeight - edgePixels * 5) / 6; // floor
        final int itemWidthPixels = itemHeightPixels;

        LiveTranscoding.Layout.Builder layoutBuilder = new LiveTranscoding.Layout.Builder();
        LiveTranscoding.Region selfRegion = new LiveTranscoding.Region()
                .uid(userId)
                .setLocalUser(true)
                .roomId(roomId)
                .position(0, 0)
                .size((double) (videoWidth - itemWidthPixels - edgePixels) / videoWidth, 1.0)
                .alpha(1)
                .zorder(0);
        layoutBuilder.addRegion(selfRegion);

        final double itemWidth = (double) itemWidthPixels / videoWidth;
        final double itemHeight = (double) itemHeightPixels / videoHeight;

        final double itemX = 1.0 - itemWidth;

        final double edgeHeight = (double) edgePixels / videoHeight;

        for (int index = 0; index < audienceIds.size(); index++) {
            LiveTranscoding.Region region = new LiveTranscoding.Region()
                    .uid(audienceIds.get(index))
                    .roomId(roomId)
                    .position(itemX, (itemHeight + edgeHeight) * index)
                    .size(itemWidth, itemHeight)
                    .alpha(1)
                    .zorder(1);
            layoutBuilder.addRegion(region);
        }

        layoutBuilder.appData(appData(LiveMode.LINK_1vN))
                .backgroundColor("#0D0B53");
        liveTranscoding.setLayout(layoutBuilder.builder());

        return liveTranscoding;
    }
    // endregion

    private void startSingleLiveTranscoding() {
        if (PUSH_MODE == PushMode.RTC) {
            stopLiveCorePush();

            LiveTranscoding liveTranscoding = createSingleLiveTranscodingConfig();
            startOrUpdateRTCTranscoding(liveTranscoding);
        } else {
            stopRTCTranscoding();

            startLiveCorePush();
        }
    }

    private void startOrUpdateRTCTranscoding(LiveTranscoding transcoding) {
        if (mRTCVideo != null) {
            if (mIsRTCTranscoding) {
                mRTCVideo.updateLiveTranscoding("", transcoding);
            } else {
                if (PUSH_MODE == PushMode.LIVE_CORE) {
                    stopLiveCorePush();
                }

                mIsRTCTranscoding = true;
                mRTCVideo.startLiveTranscoding("", transcoding, mILiveTranscodingObserver);
            }
        }
    }

    private void stopRTCTranscoding() {
        mIsRTCTranscoding = false;
        if (mRTCVideo != null) {
            mRTCVideo.stopLiveTranscoding("");
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
        mHolder.changeConfig(myConfig.width,
                myConfig.height,
                myConfig.frameRate,
                myConfig.bitRate * 1000); // RTC bitrate Kbps, LiveCore bitrate bps

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
