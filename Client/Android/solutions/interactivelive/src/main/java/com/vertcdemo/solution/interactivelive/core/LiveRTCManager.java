// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import static com.ss.bytertc.engine.VideoCanvas.RENDER_MODE_HIDDEN;

import android.app.Application;
import android.util.Log;
import android.view.TextureView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCEngine;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.data.CameraId;
import com.ss.bytertc.engine.data.EngineConfig;
import com.ss.bytertc.engine.data.ForwardStreamEventInfo;
import com.ss.bytertc.engine.data.ForwardStreamInfo;
import com.ss.bytertc.engine.data.ForwardStreamStateInfo;
import com.ss.bytertc.engine.data.MirrorType;
import com.ss.bytertc.engine.data.StreamInfo;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.LocalStreamStats;
import com.ss.bytertc.engine.type.NetworkQualityStats;
import com.ss.bytertc.engine.video.IVideoEffect;
import com.ss.bytertc.engine.video.VideoCaptureConfig;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.event.RTCNetworkQualityEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.rtc.IRTCManager;
import com.vertcdemo.core.rts.RTCRoomEventHandlerWithRTS;
import com.vertcdemo.core.rts.RTCVideoEventHandlerWithRTS;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveRoleType;
import com.vertcdemo.solution.interactivelive.core.live.StatisticsInfo;
import com.vertcdemo.solution.interactivelive.event.PublishVideoStreamEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class LiveRTCManager extends VideoTranscoding implements IRTCManager {

    private static final String TAG = "LiveRTCManager";
    // Whether is the front camera
    private boolean mIsFront = true;
    // anchor's video capture config
    private final LiveSettingConfig mHostConfig = new LiveSettingConfig(720, 1280, 15, 1600);

    @Override
    protected LiveSettingConfig getLiveConfig() {
        return mHostConfig;
    }
    // guest's video capture config
    private final LiveSettingConfig mGuestConfig = new LiveSettingConfig(256, 256, 15, 124);
    // RTC room object
    private RTCRoom mRTCRoom;
    private final LiveRTSClient mRTSClient = new LiveRTSClient();
    // RTC room id
    private String mRTCRoomId;

    // Cache the latest streamId for each userId so that subscribe/render can use streamId (3.60+).
    private final HashMap<String, String> mUserStreamIdMap = new HashMap<>();

    private static final LiveRTCManager sInstance = new LiveRTCManager();
    // RTS object, used to realize the long link of the business server
    private RTCRoom mRTSRoom = null;

    private final RTCVideoEventHandlerWithRTS mRTCVideoEventHandler = new RTCVideoEventHandlerWithRTS(mRTSClient);
    // RTS object callback
    private final RTCRoomEventHandlerWithRTS mRTSRoomEventHandler = new RTCRoomEventHandlerWithRTS(mRTSClient, true);
    // RTC room event callback
    private final RTCRoomEventHandlerWithRTS mRTCRoomEventHandler = new RTCRoomEventHandlerWithRTS(mRTSClient, false) {

        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            Log.d(TAG, String.format("onRoomStateChanged: %s, %s, %d, %s", roomId, uid, state, extraInfo));
            mRTCRoomId = roomId;
            if (isFirstJoinRoomSuccess(state, extraInfo)) {
                startLiveTranscoding(roomId, uid);
            }
        }

        @Override
        public void onUserJoined(UserInfo userInfo) {
            String uid = userInfo.getUid();
            Log.d(TAG, "onUserJoined : uid=" + uid);
        }

        @Override
        public void onUserLeave(String uid, int reason) {
            Log.d(TAG, "onUserLeave : uid=" + uid);
        }

        @Override
        public void onUserPublishStreamAudio(String roomId, StreamInfo streamInfo, boolean isPublish) {
            if (isPublish && streamInfo != null) {
                mUserStreamIdMap.put(streamInfo.userId, streamInfo.streamId);
            }
        }

        @Override
        public void onUserPublishStreamVideo(String roomId, StreamInfo streamInfo, boolean isPublish) {
            if (isPublish && streamInfo != null) {
                mUserStreamIdMap.put(streamInfo.userId, streamInfo.streamId);
                SolutionEventBus.post(new PublishVideoStreamEvent(streamInfo.userId, streamInfo.streamId, mRTCRoomId));
            }
        }

        @Override
        public void onForwardStreamStateChanged(ForwardStreamStateInfo[] stateInfos) {
            super.onForwardStreamStateChanged(stateInfos);
        }

        @Override
        public void onForwardStreamEvent(ForwardStreamEventInfo[] eventInfos) {
            super.onForwardStreamEvent(eventInfos);
            if (eventInfos != null) {
                for (ForwardStreamEventInfo info : eventInfos) {
                    Log.d(TAG, String.format("onForwardStreamEvent: %s", info));
                }
            }
        }

        @Override
        public void onNetworkQuality(NetworkQualityStats localQuality, NetworkQualityStats[] remoteQualities) {
            SolutionEventBus.post(new RTCNetworkQualityEvent(localQuality, remoteQualities));
        }

        @Override
        public void onLocalStreamStats(String streamId, StreamInfo streamInfo, LocalStreamStats stats) {
            Log.d(TAG, String.format("onLocalStreamStats: %s, %s, %s", streamId, streamInfo, stats));
            StatisticsInfo statisticsInfo = new StatisticsInfo();
            statisticsInfo.encodeFps = stats.videoStats.encoderOutputFrameRate;
            statisticsInfo.transportFps = stats.videoStats.sentFrameRate;
            statisticsInfo.encodeVideoBitrate = stats.videoStats.encodedBitrate;
            statisticsInfo.transportVideoBitrate = stats.videoStats.sentKBitrate;
            SolutionEventBus.post(statisticsInfo);
        }
    };

    private LiveRTCManager() {
        Log.d(TAG, "RTCEngine sdkVersion: " + RTCEngine.getSDKVersion());
    }

    public static LiveRTCManager ins() {
        return sInstance;
    }

    @Override
    public void createEngine(@NonNull String appId, @Nullable String bid) {
        Log.d(TAG, "createRTCEngine: appId='" + appId + "'; bid='" + bid + "'");
        if (mRTCVideo != null) {
            Log.w(TAG, "createRTCEngine: already created");
            return;
        }

        final Application context = AppUtil.getApplicationContext();
        EngineConfig engineConfig = new EngineConfig();
        engineConfig.context = context;
        engineConfig.appID = appId;
        engineConfig.isGameScene = false;

        RTCEngine rtcEngine = RTCEngine.createRTCEngine(engineConfig, mRTCVideoEventHandler);
        rtcEngine.setBusinessId(bid);

        rtcEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);
        rtcEngine.setVideoCaptureConfig(mHostConfig.toCaptureConfig());

        VideoEncoderConfig encoderConfig = mHostConfig.toEncoderConfig();
        Log.d(TAG, "setVideoEncoderConfig: " + encoderConfig);
        rtcEngine.setVideoEncoderConfig(encoderConfig);

        mRTCVideo = rtcEngine;
    }

    @Override
    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");
        stopLive();
        leaveRTSRoom();
        if (mRTCVideo != null) {
            RTCEngine.destroyRTCEngine();
            mRTCVideo = null;
        }
        setMicOn(true);
        setCameraOn(true);
    }

    private final HashMap<String, String> mRTCRoomInfos = new HashMap<>();

    public void startLive(String roomId, String token, String pushUrl, LiveUserInfo info) {
        Log.d(TAG, "startLive: roomId=" + roomId);
        final String userId = info.userId;
        mRTCRoomInfos.put("room_id", roomId);
        mRTCRoomInfos.put("user_id", userId);
        mRTCRoomInfos.put("user_token", token);

        setLiveInfo(new LiveInfoHost(roomId, userId, pushUrl));
        joinRoom(roomId, userId, token);
    }

    public void stopLive() {
        stopLiveTranscoding();
        leaveRoom();
        stopAllCapture();
        setFrontCamera(true);
    }

    public void joinRoom(String roomId, String userId, String token) {
        Log.d(TAG, "joinRoom: roomId='" + roomId + "'; userId='" + userId + "'");
        assert mRTCVideo != null;
        if (mRTCRoom != null) {
            Log.e(TAG, "WARN: already in ROOM");
            return;
        }
        mRTCRoomId = roomId;
        mRTCRoom = mRTCVideo.createRTCRoom(roomId);
        assert mRTCRoom != null : "createRTCRoom: failed to createRoom: roomId=" + roomId;
        mRTCRoom.setRTCRoomEventHandler(mRTCRoomEventHandler);
        UserInfo userInfo = new UserInfo(userId, null);
        RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_INTERACTIVE_PODCAST,
                true,
                true,
                true,
                true);
        mRTCRoom.joinRoom(token, userInfo, true, roomConfig);
    }

    public void startCoHostPK(String coHostRoomId, String coHostRtcToken, LiveUserInfo coHostInfo) {
        Log.d(TAG, "startCoHostPK: roomId=" + coHostRoomId + "; coHost=" + coHostInfo);
        setCoHostVideoConfig(coHostInfo);

        setCoHostInfo(new LiveInfoHost(coHostRoomId, coHostInfo.userId));

        assert mRTCRoom != null : "Must be in RTCRoom!";
        ForwardStreamInfo forwardStreamInfo = new ForwardStreamInfo(coHostRoomId, coHostRtcToken);
        mRTCRoom.stopForwardStreamToRooms();
        int res = mRTCRoom.startForwardStreamToRooms(Collections.singletonList(forwardStreamInfo));
        Log.d(TAG, "startForwardStreamToRooms: " + res);
    }

    /**
     * Set the resolution information of the Lianmai anchor according to the extra
     * field of the user information of the business server
     *
     * @param userInfo anchor information
     */
    private void setCoHostVideoConfig(LiveUserInfo userInfo) {
        if (userInfo == null) {
            return;
        }
        int width = 0;
        int height = 0;
        try {
            JSONObject ext = new JSONObject(userInfo.extra);
            width = ext.getInt("width");
            height = ext.getInt("height");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        super.setCoHostVideoConfig(width, height);
    }

    public void stopCoHostPK() {
        Log.d(TAG, "stopCoHostPK");
        setCoHostVideoConfig(0, 0);
        super.stopLiveTranscodingWithHost();
        mCoHostInfo = null;
        if (mRTCRoom != null) {
            mRTCRoom.stopForwardStreamToRooms();
        }
    }

    public void updateLinkWithAudiences(List<String> audienceIds) {
        Log.d(TAG, "updateLinkWithAudiences: " + Arrays.toString(audienceIds.toArray()));
        updateLiveTranscodingWithAudience(audienceIds);
    }

    public void stopLinkWithAudiences() {
        Log.d(TAG, "stopLinkWithAudiences: ");
        updateLiveTranscodingWithAudience(Collections.emptyList());
    }

    public void startCapture(boolean video, boolean audio) {
        startCaptureVideo(video);
        startCaptureAudio(audio);
    }

    public void startCaptureVideo(boolean on) {
        Log.d(TAG, "startCaptureVideo : " + on);
        if (mRTCVideo != null) {
            if (on) {
                mRTCVideo.startVideoCapture();
            } else {
                mRTCVideo.stopVideoCapture();
            }
        }
        setCameraOn(on);
    }

    /**
     * Toggle Camera ON/OFF
     *
     * @return true: camera on, off: camera off
     */
    public boolean toggleCamera() {
        final boolean newValue = !isCameraOn();
        startCaptureVideo(newValue);
        postMediaStatus();
        return isCameraOn();
    }

    public void startCaptureAudio(boolean on) {
        Log.d(TAG, "startCaptureAudio : " + on);
        if (mRTCVideo != null) {
            if (on) {
                mRTCVideo.startAudioCapture();
            } else {
                mRTCVideo.stopAudioCapture();
            }
        }
        setMicOn(on);
    }

    public boolean toggleMicrophone() {
        boolean newValue = !isMicOn();
        startCaptureAudio(newValue);
        postMediaStatus();
        return isMicOn();
    }

    public void stopAllCapture() {
        startCapture(false, false);
    }

    public void leaveRoom() {
        Log.d(TAG, "leaveRoom");
        if (mRTCRoom != null) {
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
        }
        mRTCRoom = null;
    }

    public void setFrontCamera(boolean isFront) {
        if (mRTCVideo != null) {
            mRTCVideo.switchCamera(isFront ? CameraId.CAMERA_ID_FRONT : CameraId.CAMERA_ID_BACK);
            mRTCVideo.setLocalVideoMirrorType(isFront ? MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER : MirrorType.MIRROR_TYPE_NONE);
        }
        mIsFront = isFront;
    }

    public void switchCamera() {
        setFrontCamera(!mIsFront);
    }

    private void postMediaStatus() {
        UserMediaChangedEvent event = new UserMediaChangedEvent();
        String selfUid = SolutionDataManager.ins().getUserId();
        event.userId = selfUid;
        event.operatorUserId = selfUid;
        event.mic = isMicOn() ? MediaStatus.ON : MediaStatus.OFF;
        event.camera = isCameraOn() ? MediaStatus.ON : MediaStatus.OFF;
        SolutionEventBus.post(event);
    }

    public void setLocalVideoView(@Nullable TextureView view) {
        if (mRTCVideo == null) {
            return;
        }
        Log.d(TAG, "setLocalVideoView");
        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = view;
        videoCanvas.renderMode = RENDER_MODE_HIDDEN;
        mRTCVideo.setLocalVideoCanvas(videoCanvas);
    }

    public void setRemoteVideoView(String streamId, TextureView view) {
        Log.d(TAG, "setRemoteVideoView : streamId='" + streamId + "'");
        if (mRTCVideo == null || mRTCRoomId == null) {
            return;
        }
        VideoCanvas canvas = new VideoCanvas();
        canvas.renderView = view;
        canvas.renderMode = RENDER_MODE_HIDDEN;
        mRTCVideo.setRemoteVideoCanvas(streamId, canvas);
    }

    public void switchToAudienceConfig() {
        updateVideoConfig(mGuestConfig.width,
                mGuestConfig.height,
                mGuestConfig.frameRate,
                mGuestConfig.bitRate);
    }

    public void switchToHostConfig() {
        updateVideoConfig(mHostConfig.width,
                mHostConfig.height,
                mHostConfig.frameRate,
                mHostConfig.bitRate);
    }

    public LiveSettingConfig getLiveConfigByRole(@LiveRoleType int role) {
        try {
            switch (role) {
                case LiveRoleType.HOST:
                    return mHostConfig;
                case LiveRoleType.AUDIENCE:
                    return mGuestConfig;
                default:
                    Log.e(TAG, "Unknown role type: " + role + ", fallback to host config");
                    return mHostConfig;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error getting live config for role: " + role, e);
            return mHostConfig;
        }
    }

    public void setFrameRate(@LiveRoleType int role, int frameRate) {
        LiveSettingConfig config = getLiveConfigByRole(role);
        if (config != null) {
            config.frameRate = frameRate;
            updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
        }
    }

    public void setResolution(@LiveRoleType int role, int width, int height, int bitrate) {
        LiveSettingConfig config = getLiveConfigByRole(role);
        if (config != null) {
            config.width = width;
            config.height = height;
            config.bitRate = bitrate;
            updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
        }
    }

    public void setBitrate(@LiveRoleType int role, int bitRate) {
        LiveSettingConfig config = getLiveConfigByRole(role);
        if (config == null || bitRate == config.bitRate) {
            return;
        }
        config.bitRate = bitRate;
        updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
    }

    public int getBitrate(@LiveRoleType int role) {
        return getLiveConfigByRole(role).bitRate;
    }

    public int getFrameRate(@LiveRoleType int role) {
        return getLiveConfigByRole(role).frameRate;
    }

    public int getWidth(@LiveRoleType int role) {
        return getLiveConfigByRole(role).width;
    }

    public int getHeight(@LiveRoleType int role) {
        return getLiveConfigByRole(role).height;
    }

    private void updateVideoConfig(int width, int height, int frameRate, int bitRate) {
        if (isTranscoding()) {
            Log.d(TAG, "updateVideoConfig: Can't update when isTranscoding=true");
            return;
        }
        if (mRTCVideo != null) {
            VideoEncoderConfig config = new VideoEncoderConfig();
            config.width = width;
            config.height = height;
            config.frameRate = frameRate;
            config.maxBitrate = bitRate;
            mRTCVideo.setVideoEncoderConfig(config);
            Log.d(TAG, "updateVideoConfig: width=" + width
                    + "; height=" + height
                    + "; frameRate=" + frameRate
                    + "; bitRate=" + bitRate
            );

            VideoCaptureConfig captureConfig = new VideoCaptureConfig(width, height, frameRate);
            mRTCVideo.setVideoCaptureConfig(captureConfig);
        }
    }

    public void joinRTSRoom(String rtsRoomId, String userId, String token) {
        Log.d(TAG, "joinRTSRoom: roomId='" + rtsRoomId + "'; userId='" + userId + "'");
        if (mRTCVideo == null) {
            return;
        }
        if (mRTSRoom != null) {
            mRTSRoom.destroy();
        }
        mRTSRoom = mRTCVideo.createRTCRoom(rtsRoomId);
        mRTSRoom.setRTCRoomEventHandler(mRTSRoomEventHandler);
        UserInfo userInfo = new UserInfo(userId, null);
        RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_INTERACTIVE_PODCAST,
                false, false, false, false);
        mRTSRoom.joinRoom(token, userInfo, false, roomConfig);
    }

    public void leaveRTSRoom() {
        Log.d(TAG, "leaveRTSRoom: ");
        if (mRTSRoom == null) {
            return;
        }
        mRTSRoom.leaveRoom();
        mRTSRoom.destroy();
        mRTSRoom = null;
    }

    public IVideoEffect getVideoEffectInterface() {
        assert mRTCVideo != null;
        return mRTCVideo.getVideoEffectInterface();
    }
}
