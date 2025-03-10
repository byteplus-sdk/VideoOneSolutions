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
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.data.CameraId;
import com.ss.bytertc.engine.data.ForwardStreamEventInfo;
import com.ss.bytertc.engine.data.ForwardStreamInfo;
import com.ss.bytertc.engine.data.ForwardStreamStateInfo;
import com.ss.bytertc.engine.data.MirrorType;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
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

    private static final LiveRTCManager sInstance = new LiveRTCManager();
    // RTS object, used to realize the long link of the business server
    private RTCRoom mRTSRoom = null;
    private String mRTSRoomId = null;

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
                if (PUSH_MODE == PushMode.RTC) {
                    startLiveTranscoding(roomId, uid);
                }
            }
        }

        @Override
        public void onUserJoined(UserInfo userInfo, int elapsed) {
            String uid = userInfo.getUid();
            Log.d(TAG, "onUserJoined : uid=" + uid);
        }

        @Override
        public void onUserLeave(String uid, int reason) {
            Log.d(TAG, "onUserLeave : uid=" + uid);
        }

        @Override
        public void onUserPublishStream(String uid, MediaStreamType type) {
            super.onUserPublishStream(uid, type);

            handleUserPublishStream(uid, type);

            if (type == MediaStreamType.RTC_MEDIA_STREAM_TYPE_VIDEO
                    || type == MediaStreamType.RTC_MEDIA_STREAM_TYPE_BOTH) {
                SolutionEventBus.post(new PublishVideoStreamEvent(uid, mRTCRoomId));
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
    };

    private LiveRTCManager() {
        Log.d(TAG, "RTCVideo sdkVersion: " + RTCVideo.getSDKVersion());
    }

    public static LiveRTCManager ins() {
        return sInstance;
    }

    @Override
    public void createEngine(@NonNull String appId, @Nullable String bid) {
        Log.d(TAG, "createRTCVideo: appId='" + appId + "'; bid='" + bid + "'");
        if (mRTCVideo != null) {
            Log.w(TAG, "createRTCVideo: already created");
            return;
        }

        final Application context = AppUtil.getApplicationContext();
        RTCVideo rtcVideo = RTCVideo.createRTCVideo(context, appId, mRTCVideoEventHandler, null, null);
        rtcVideo.setBusinessId(bid);

        rtcVideo.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);
        rtcVideo.setVideoCaptureConfig(mHostConfig.toCaptureConfig());

        VideoEncoderConfig config = mHostConfig.toEncoderConfig();
        Log.d(TAG, "setVideoEncoderConfig: " + config);
        rtcVideo.setVideoEncoderConfig(config);

        mRTCVideo = rtcVideo;
    }

    @Override
    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");

        stopLive();
        leaveRTSRoom();

        if (mRTCVideo != null) {
            RTCVideo.destroyRTCVideo();
            mRTCVideo = null;
        }

        release();

        setMicOn(true);
        setCameraOn(true);
    }

    public LiveRTSClient getRTSClient() {
        return mRTSClient;
    }

    public static LiveRTSClient rts() {
        return ins().getRTSClient();
    }

    private final HashMap<String, String> mRTCRoomInfos = new HashMap<>();

    public void startLive(String roomId, String token, String pushUrl, LiveUserInfo info) {
        Log.d(TAG, "startLive: roomId=" + roomId);
        final String userId = info.userId;
        mRTCRoomInfos.put("room_id", roomId);
        mRTCRoomInfos.put("user_id", userId);
        mRTCRoomInfos.put("user_token", token);

        setLiveInfo(new LiveInfoHost(roomId, userId, pushUrl));

        if (PUSH_MODE == PushMode.RTC) {
            joinRoom(roomId, userId, token);
        } else {
            startLiveTranscoding(roomId, userId);
        }
    }

    public void stopLive() {
        stopLiveTranscoding();
        leaveRoom();
        stopAllCapture();
        setFrontCamera(true);

        releaseLiveCore();
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
                true);
        mRTCRoom.joinRoom(token, userInfo, roomConfig);
    }

    public void startCoHostPK(String coHostRoomId, String coHostRtcToken, LiveUserInfo coHostInfo) {
        Log.d(TAG, "startCoHostPK: roomId=" + coHostRoomId + "; coHost=" + coHostInfo);
        setCoHostVideoConfig(coHostInfo);

        setCoHostInfo(new LiveInfoHost(coHostRoomId, coHostInfo.userId));

        if (PUSH_MODE == PushMode.LIVE_CORE) {
            ensureJoinRTCRoom();
        }

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

        if (PUSH_MODE == PushMode.LIVE_CORE) {
            leaveRoom();
        }
    }

    public void updateLinkWithAudiences(List<String> audienceIds) {
        Log.d(TAG, "updateLinkWithAudiences: " + Arrays.toString(audienceIds.toArray()));
        updateLiveTranscodingWithAudience(audienceIds);
    }

    public void stopLinkWithAudiences() {
        Log.d(TAG, "stopLinkWithAudiences: ");
        updateLiveTranscodingWithAudience(Collections.emptyList());

        if (PUSH_MODE == PushMode.LIVE_CORE) {
            leaveRoom();
        }
    }

    private void ensureJoinRTCRoom() {
        Log.d(TAG, "ensureJoinRTCRoom: ");
        String roomId = mRTCRoomInfos.get("room_id");
        String userId = mRTCRoomInfos.get("user_id");
        String token = mRTCRoomInfos.get("user_token");
        joinRoom(roomId, userId, token);
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

    public boolean isFrontCamera() {
        return mIsFront;
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
        mRTCVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
    }

    public void setRemoteVideoView(String userId, TextureView view) {
        Log.d(TAG, "setRemoteVideoView : userId='" + userId + "'");
        if (mRTCVideo == null || mRTCRoomId == null) {
            return;
        }
        VideoCanvas canvas = new VideoCanvas();
        canvas.renderView = view;
        canvas.renderMode = RENDER_MODE_HIDDEN;

        final RemoteStreamKey streamKey = new RemoteStreamKey(mRTCRoomId, userId, StreamIndex.STREAM_INDEX_MAIN);
        mRTCVideo.setRemoteVideoCanvas(streamKey, canvas);
    }

    public void muteRemoteAudio(String uid, boolean mute) {
        Log.d(TAG, "muteRemoteAudio uid:" + uid + ",mute:" + mute);
        if (mRTCRoom != null) {
            if (mute) {
                mRTCRoom.unsubscribeStream(uid, MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
            } else {
                mRTCRoom.subscribeStream(uid, MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
            }
        }
        updateLiveTranscodingWhenMuteCoHost(uid, mute);
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

    public void setFrameRate(@LiveRoleType int role, int frameRate) {
        LiveSettingConfig config = role == LiveRoleType.HOST ? mHostConfig : mGuestConfig;
        config.frameRate = frameRate;
        updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
    }

    public void setResolution(@LiveRoleType int role, int width, int height, int bitrate) {
        LiveSettingConfig config = role == LiveRoleType.HOST ? mHostConfig : mGuestConfig;
        config.width = width;
        config.height = height;
        config.bitRate = bitrate;
        updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
    }

    public void setBitrate(@LiveRoleType int role, int bitRate) {
        LiveSettingConfig config = role == LiveRoleType.HOST ? mHostConfig : mGuestConfig;
        if (bitRate == config.bitRate) {
            return;
        }
        config.bitRate = bitRate;
        updateVideoConfig(config.width, config.height, config.frameRate, config.bitRate);
    }

    public int getBitrate(@LiveRoleType int role) {
        return role == LiveRoleType.HOST ? mHostConfig.bitRate : mGuestConfig.bitRate;
    }

    public int getFrameRate(@LiveRoleType int role) {
        return role == LiveRoleType.HOST ? mHostConfig.frameRate : mGuestConfig.frameRate;
    }

    public int getWidth(@LiveRoleType int role) {
        return role == LiveRoleType.HOST ? mHostConfig.width : mGuestConfig.width;
    }

    public int getHeight(@LiveRoleType int role) {
        return role == LiveRoleType.HOST ? mHostConfig.height : mGuestConfig.height;
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
        mRTSRoomId = rtsRoomId;
        mRTSRoom = mRTCVideo.createRTCRoom(rtsRoomId);
        mRTSRoom.setRTCRoomEventHandler(mRTSRoomEventHandler);
        UserInfo userInfo = new UserInfo(userId, null);
        RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_INTERACTIVE_PODCAST, false, false, false);
        mRTSRoom.joinRoom(token, userInfo, roomConfig);
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
