// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;

import static com.ss.bytertc.engine.data.AudioFrameCallbackMethod.AUDIO_FRAME_CALLBACK_REMOTE_USER;
import static com.ss.bytertc.engine.data.AudioMixingDualMonoMode.AUDIO_MIXING_DUAL_MONO_MODE_L;
import static com.ss.bytertc.engine.data.AudioMixingDualMonoMode.AUDIO_MIXING_DUAL_MONO_MODE_R;
import static com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH;

import android.app.Application;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.IMediaPlayerEventHandler;
import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.audio.IMediaPlayer;
import com.ss.bytertc.engine.data.AudioChannel;
import com.ss.bytertc.engine.data.AudioFormat;
import com.ss.bytertc.engine.data.AudioPropertiesConfig;
import com.ss.bytertc.engine.data.AudioRoute;
import com.ss.bytertc.engine.data.AudioSampleRate;
import com.ss.bytertc.engine.data.EarMonitorMode;
import com.ss.bytertc.engine.data.LocalAudioPropertiesInfo;
import com.ss.bytertc.engine.data.MediaPlayerConfig;
import com.ss.bytertc.engine.data.MirrorType;
import com.ss.bytertc.engine.data.PlayerError;
import com.ss.bytertc.engine.data.PlayerState;
import com.ss.bytertc.engine.data.RemoteAudioPropertiesInfo;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.StreamSycnInfoConfig;
import com.ss.bytertc.engine.type.AudioProfileType;
import com.ss.bytertc.engine.type.AudioScenarioType;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.NetworkQualityStats;
import com.ss.bytertc.engine.type.VoiceReverbType;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.event.AudioRouteChangedEvent;
import com.vertcdemo.core.event.NetworkStatusEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.rtc.IRTCManager;
import com.vertcdemo.core.rts.RTCRoomEventHandlerWithRTS;
import com.vertcdemo.core.rts.RTCVideoEventHandlerWithRTS;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.chorus.event.NetworkTypeChangedEvent;
import com.vertcdemo.solution.chorus.event.PlayFinishEvent;
import com.vertcdemo.solution.chorus.event.PlayProgressEvent;
import com.vertcdemo.solution.chorus.event.RTCUserJoinEvent;
import com.vertcdemo.solution.chorus.event.SDKAudioVolumeEvent;
import com.vertcdemo.solution.chorus.event.UserVideoEvent;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

public class ChorusRTCManager implements IRTCManager {

    private static final boolean DEBUG = false;

    private static final String TAG = "ChorusRTCManager";
    private static ChorusRTCManager sInstance;
    private RTCVideo mRTCVideo;
    private RTCRoom mRTCRoom;
    private final ChorusRTSClient mRTSClient = new ChorusRTSClient();
    private String mRoomId;

    private volatile String mCurrentMusicId; // 当前混音音乐id

    /***音频帧监听，如果为空则没有转发*/
    private ForwardAudioFrameObserver mAudioFrameObserver;

    /***被取消订阅音频的用户Uid,如果为空则没有用户音频被取消订阅*/
    private final Set<String> mUnsubscribeAudioUids = new HashSet<>();
    private final Set<String> mHasVideoUids = new HashSet<>();

    /**
     * 通知用户的视频状态发生了变化
     *
     * @param uid      用户id
     * @param hasVideo 视频状态
     */
    void notifyVideoStatusChanged(String uid, boolean hasVideo) {
        if (hasVideo) {
            mHasVideoUids.add(uid);
        } else {
            mHasVideoUids.remove(uid);
        }

        SolutionEventBus.post(new UserVideoEvent(uid, hasVideo));
    }

    public boolean hasVideo(String uid) {
        return mHasVideoUids.contains(uid);
    }

    private final IMediaPlayerEventHandler mPlayerEventHandler = new IMediaPlayerEventHandler() {
        @Override
        public void onMediaPlayerStateChanged(int playerId, PlayerState state, PlayerError error) {
            Log.d(TAG, "onMediaPlayerStateChanged: state=" + state + ", error=" + error);
            guard(() -> {
                if (state == PlayerState.FINISHED) {
                    SolutionEventBus.post(new PlayFinishEvent(mCurrentMusicId));
                    mCurrentMusicId = null;
                }
            });
        }

        @Override
        public void onMediaPlayerPlayingProgress(int playerId, long progress) {
            guard(() -> {
                if (mChorusInfo.isLeaderSinger()) {
                    syncProgressToRemote(mCurrentMusicId, progress);
                }
                SolutionEventBus.post(new PlayProgressEvent(progress));
            });
        }
    };

    private final RTCVideoEventHandlerWithRTS mRTCVideoEventHandler = new RTCVideoEventHandlerWithRTS(mRTSClient) {

        @Override
        public void onWarning(int warn) {
            super.onWarning(warn);
            Log.d(TAG, String.format("onWarning: %d", warn));
        }

        @Override
        public void onError(int err) {
            super.onError(err);
            Log.d(TAG, String.format("onError: %d", err));
        }

        /****
         * 远端播放进度广播通过此回调接收
         */
        @Override
        public void onStreamSyncInfoReceived(RemoteStreamKey streamKey, StreamSycnInfoConfig.SyncInfoStreamType streamType, ByteBuffer data) {
            try {
                String message = StandardCharsets.UTF_8.newDecoder().decode(data).toString();
                JSONObject json = new JSONObject(message);
                long progress = json.getLong("progress");
                if (progress <= 0) {
                    return;
                }
                // 因为观众不订阅主唱音频，而进度信息跟随音频发布，因此需要副唱转发主唱发出的进度
                if (mChorusInfo.isSupportingSinger()) {
                    syncProgressToRemote(message);
                }
                SolutionEventBus.post(new PlayProgressEvent(progress));
            } catch (CharacterCodingException | JSONException e) {
                Log.d(TAG, "onStreamSyncInfoReceived exception: ", e);
            }
        }

        @Override
        public void onAudioRouteChanged(AudioRoute device) {
            Log.d(TAG, "onAudioRouteChanged device:" + device);
            SolutionEventBus.post(new AudioRouteChangedEvent(device));
        }

        @Override
        public void onNetworkTypeChanged(int type) {
            Log.d(TAG, "onNetworkTypeChanged:" + type);
            SolutionEventBus.post(new NetworkTypeChangedEvent(type));
        }

        @Override
        public void onUserStartVideoCapture(String roomId, String uid) {
            Log.d(TAG, "onUserStartVideoCapture: roomId: " + roomId + ", uid: " + uid);
            if (TextUtils.equals(mRoomId, roomId)) {
                notifyVideoStatusChanged(uid, true); // onUserStartVideoCapture
            }
        }

        @Override
        public void onUserStopVideoCapture(String roomId, String uid) {
            Log.d(TAG, "onUserStopVideoCapture: roomId: " + roomId + ", uid: " + uid);
            if (TextUtils.equals(mRoomId, roomId)) {
                notifyVideoStatusChanged(uid, false); // onUserStopVideoCapture
            }
        }

        /**
         * 本地音频包括使用 RTC SDK 内部机制采集的麦克风音频和屏幕音频。
         * @param audioPropertiesInfos 本地音频信息，详见 LocalAudioPropertiesInfo 。
         */
        @Override
        public void onLocalAudioPropertiesReport(LocalAudioPropertiesInfo[] audioPropertiesInfos) {
            super.onLocalAudioPropertiesReport(audioPropertiesInfos);
            if (audioPropertiesInfos == null || !mChorusInfo.isSinger()) {
                return;
            }
            for (LocalAudioPropertiesInfo info : audioPropertiesInfos) {
                if (info.streamIndex == StreamIndex.STREAM_INDEX_MAIN) {
                    if (DEBUG) {
                        Log.d(TAG, "onLocalAudioPropertiesReport: " + mChorusInfo.myUid
                                + ", linearVolume: " + info.audioPropertiesInfo.linearVolume);
                    }
                    SolutionEventBus.post(new SDKAudioVolumeEvent(
                            mChorusInfo.myUid,
                            info.audioPropertiesInfo.linearVolume));
                }
            }
        }

        /**
         * 远端用户的音频包括使用 RTC SDK 内部机制/自定义机制采集的麦克风音频和屏幕音频。
         *
         * @param audioPropertiesInfos 远端音频信息，其中包含音频流属性、房间 ID、用户 ID ，详见 RemoteAudioPropertiesInfo。
         * @param totalRemoteVolume    订阅的所有远端流的总音量。
         */
        @Override
        public void onRemoteAudioPropertiesReport(RemoteAudioPropertiesInfo[] audioPropertiesInfos, int totalRemoteVolume) {
            super.onRemoteAudioPropertiesReport(audioPropertiesInfos, totalRemoteVolume);
            if (audioPropertiesInfos == null) {
                return;
            }
            for (RemoteAudioPropertiesInfo info : audioPropertiesInfos) {
                if (info.streamKey.getStreamIndex() == StreamIndex.STREAM_INDEX_MAIN) {
                    String userId = info.streamKey.getUserId();
                    if (mChorusInfo.isSinger(userId)) {
                        if (DEBUG) {
                            Log.d(TAG, "onRemoteAudioPropertiesReport: " + userId
                                    + ", linearVolume: " + info.audioPropertiesInfo.linearVolume);
                        }
                        SolutionEventBus.post(new SDKAudioVolumeEvent(
                                userId,
                                info.audioPropertiesInfo.linearVolume));
                    }
                }
            }
        }
    };

    private final RTCRoomEventHandlerWithRTS mRTCRoomEventHandler = new RTCRoomEventHandlerWithRTS(mRTSClient, true) {

        /**
         *
         * @param roomId 房间 ID
         * @param uid 用户 ID
         * @param state 房间状态码。0: 成功。!0: 失败
         * @param extraInfo 额外信息。joinType表示加入房间的类型，0为首次进房，1为重连进房。
         *                  elapsed表示加入房间耗时，即本地用户从调用 joinRoom 到加入房间成功所经历的时间间隔，单位为 ms。
         */
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            Log.d(TAG, String.format("onRoomStateChanged: %s, %s,%d,%s", roomId, uid, state, extraInfo));
            if (isFirstJoinRoomSuccess(state, extraInfo)) {
                SolutionEventBus.post(new RTCUserJoinEvent(uid));
            }
            mRoomId = roomId;
        }

        @Override
        public void onUserJoined(UserInfo userInfo, int elapsed) {
            super.onUserJoined(userInfo, elapsed);
            Log.d(TAG, "onUserJoined: " + userInfo.uid);
        }

        @Override
        public void onUserLeave(String uid, int reason) {
            Log.d(TAG, "onUserLeave: " + uid);
        }

        @Override
        public void onNetworkQuality(NetworkQualityStats localQuality, NetworkQualityStats[] remoteQualities) {
            HashMap<String, Integer> data = new HashMap<>();
            if (mChorusInfo.isSinger()) {
                data.put(mChorusInfo.myUid, localQuality.txQuality);
            }
            for (NetworkQualityStats stats : remoteQualities) {
                if (mChorusInfo.isSinger(stats.uid)) {
                    data.put(stats.uid, stats.txQuality);
                }
            }
            if (!data.isEmpty()) {
                if (DEBUG) {
                    Log.d(TAG, "onNetworkQuality: ");
                }
                SolutionEventBus.post(new NetworkStatusEvent(data));
            }
        }
    };

    private ChorusRTCManager() {
        Log.d(TAG, "RTCVideo sdkVersion: " + RTCVideo.getSDKVersion());
    }

    public synchronized static ChorusRTCManager ins() {
        if (sInstance == null) {
            sInstance = new ChorusRTCManager();
        }
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
        if (bid != null) {
            rtcVideo.setBusinessId(bid);
        }

        rtcVideo.setAudioScenario(AudioScenarioType.AUDIO_SCENARIO_MUSIC);
        rtcVideo.setAudioProfile(AudioProfileType.AUDIO_PROFILE_HD);

        AudioPropertiesConfig config = new AudioPropertiesConfig(300);
        rtcVideo.enableAudioPropertiesReport(config);

        rtcVideo.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);

        mRTCVideo = rtcVideo;
    }

    @Override
    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");
        if (mRTCRoom != null) {
            Log.d(TAG, "destroyEngine: RTCRoom");
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
        }
        if (mRTCVideo != null) {
            Log.d(TAG, "destroyEngine: RTCVideo");
            RTCVideo.destroyRTCVideo();
            mRTCVideo = null;
        }
    }

    public void joinRoom(String roomId, String userId, String token) {
        leaveRoom();
        if (mRTCVideo == null) {
            return;
        }
        Log.d(TAG, String.format("joinRoom: %s %s %s", roomId, userId, token));
        mRTCRoom = mRTCVideo.createRTCRoom(roomId);
        mRTCRoom.setRTCRoomEventHandler(mRTCRoomEventHandler);
        UserInfo userInfo = new UserInfo(userId, null);
        RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_KTV,
                true, true, true);
        mRTCRoom.joinRoom(token, userInfo, roomConfig);
    }

    public void leaveRoom() {
        stopAudioMixing();
        stopForwardAudio();

        stopVideoCapture();
        stopAudioCapture();

        if (mRTCRoom != null) {
            Log.d(TAG, "leaveRoom: " + mRoomId);
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
            mHasVideoUids.clear();
            mUnsubscribeAudioUids.clear();
            mRoomId = null;
        }
    }

    public void startAudioCapture() {
        Log.d(TAG, "startAudioCapture: ");
        if (mRTCVideo == null) {
            return;
        }
        mRTCVideo.startAudioCapture();
    }

    public void stopAudioCapture() {
        Log.d(TAG, "stopAudioCapture: ");
        if (mRTCVideo == null) {
            return;
        }
        mRTCVideo.stopAudioCapture();
    }

    /**
     * 开启文件混音
     *
     * @param filePath 混音文件路径
     */
    public void startAudioMixing(String musicId, @NonNull String filePath, int volume, boolean accompany) {
        Log.d(TAG, String.format("startAudioMixing: %s", filePath));
        if (TextUtils.equals(musicId, mCurrentMusicId)) {
            Log.w(TAG, "startAudioMixing: repeat!!!");
        }
        if (mRTCVideo == null) {
            return;
        }

        IMediaPlayer player = mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        //先停止
        player.stop();
        //再播放
        player.setEventHandler(mPlayerEventHandler);
        mCurrentMusicId = musicId;
        mRTCVideo.setVoiceReverbType(VoiceReverbType.VOICE_REVERB_KTV);

        MediaPlayerConfig config = new MediaPlayerConfig();
        config.type = AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH;
        config.playCount = 1;
        config.callbackOnProgressInterval = 100;
        config.autoPlay = true;

        player.open(filePath, config);
        player.setVolume(volume, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);

        selectAudioTrack(isAccompanyMode = accompany);
    }

    public void stopAudioMixing() {
        Log.d(TAG, "stopAudioMixing: ");
        if (mRTCVideo == null) {
            return;
        }
        IMediaPlayer player = mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        player.stop();
    }

    private boolean isAccompanyMode = true;

    public boolean toggleAudioAccompanyMode() {
        Log.d(TAG, "toggleAudioAccompanyMode");
        boolean newValue = !isAccompanyMode;
        isAccompanyMode = newValue;
        selectAudioTrack(newValue);
        return newValue;
    }

    public void selectAudioTrack(boolean isAccompany) {
        Log.d(TAG, "toggleAudioAccompanyMode: " + isAccompany);
        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            return;
        }
        int trackCount = player.getAudioTrackCount();
        if (trackCount >= 2) {
            // Select Origin/Accompany use track
            if (isAccompany) {
                player.selectAudioTrack(1);
            } else {
                player.selectAudioTrack(2);
            }
        } else {
            // Select Origin/Accompany use L/R
            if (isAccompany) {
                player.setAudioDualMonoMode(AUDIO_MIXING_DUAL_MONO_MODE_R);
            } else {
                player.setAudioDualMonoMode(AUDIO_MIXING_DUAL_MONO_MODE_L);
            }
        }
    }

    public void adjustSongVolume(@IntRange(from = 0, to = 400) int volume, boolean isLeader) {
        Log.d(TAG, "adjustSongVolume: " + volume + ", isLeader: " + isLeader);
        if (mRTCVideo == null) {
            return;
        }

        String leaderUid = mChorusInfo.leaderSingerUid;
        if (isLeader && !TextUtils.isEmpty(mRoomId) && !TextUtils.isEmpty(leaderUid)) {
            // 调整自己能听到的音乐音量
            mRTCVideo.setRemoteAudioPlaybackVolume(mRoomId, leaderUid, volume);
        }

        IMediaPlayer player = mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player != null) {
            player.setVolume(volume, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);
        }
    }

    public void adjustUserVolume(@IntRange(from = 0, to = 400) int volume) {
        Log.d(TAG, "adjustUserVolume: " + volume);
        if (mRTCVideo != null) {
            mRTCVideo.setCaptureVolume(StreamIndex.STREAM_INDEX_MAIN, volume);
        }
    }

    public void adjustEarMonitorVolume(@IntRange(from = 0, to = 400) int volume) {
        Log.d(TAG, "adjustEarMonitorVolume: " + volume + ", earMonitorOpening=" + earMonitorOpening);
        if (mRTCVideo != null && earMonitorOpening) {
            mRTCVideo.setEarMonitorVolume(volume);
        }
    }

    private boolean earMonitorOpening;

    public void openEarMonitor() {
        Log.d(TAG, "openEarMonitor: ");
        mRTCVideo.setEarMonitorMode(EarMonitorMode.EAR_MONITOR_MODE_ON);
        earMonitorOpening = true;
        adjustEarMonitorVolume(100);
    }

    public void closeEarMonitor() {
        Log.d(TAG, "closeEarMonitor: ");
        mRTCVideo.setEarMonitorMode(EarMonitorMode.EAR_MONITOR_MODE_OFF);
        earMonitorOpening = false;
    }

    public void setAudioEffect(VoiceReverbType type) {
        Log.d(TAG, "setAudioEffect: " + type);
        if (mRTCVideo != null) {
            mRTCVideo.setVoiceReverbType(type);
        }
    }

    /**
     * 向远端广播播放进度
     * 方法内部需要将时间从毫秒转成秒
     *
     * @param musicId  歌曲id
     * @param progress 歌曲播放进度，单位为毫秒
     */
    public void syncProgressToRemote(@Nullable String musicId, long progress) {
        try {
            JSONObject json = new JSONObject();
            json.put("music_id", musicId == null ? "" : musicId);
            json.put("progress", progress);
            syncProgressToRemote(json.toString());
        } catch (JSONException e) {
            Log.d(TAG, "syncProgressToRemote: JSONException: ", e);
        }
    }

    void syncProgressToRemote(@NonNull String message) {
        if (mRTCVideo != null) {
            StreamSycnInfoConfig config = new StreamSycnInfoConfig(
                    StreamIndex.STREAM_INDEX_MAIN,
                    3,
                    StreamSycnInfoConfig.SyncInfoStreamType.SYNC_INFO_STREAM_TYPE_AUDIO);
            mRTCVideo.sendStreamSyncInfo(message.getBytes(StandardCharsets.UTF_8), config);
        }
    }

    /**
     * 开启视频采集
     */
    public void startVideoCapture() {
        Log.d(TAG, "startVideoCapture");
        if (mRTCVideo != null) {
            mRTCVideo.startVideoCapture();
        }
        String myUid = SolutionDataManager.ins().getUserId();
        notifyVideoStatusChanged(myUid, true); // startVideoCapture
    }

    /**
     * 关闭视频采集
     */
    public void stopVideoCapture() {
        Log.d(TAG, "stopVideoCapture");
        if (mRTCVideo != null) {
            mRTCVideo.stopVideoCapture();
        }
        String myUid = SolutionDataManager.ins().getUserId();
        notifyVideoStatusChanged(myUid, false); // stopVideoCapture
    }

    public void setRemoteVideoCanvas(String roomId, String uid, @Nullable TextureView textureView) {
        Log.d(TAG, "setRemoteVideoCanvas: roomId=" + roomId + ", uid=" + uid);
        if (mRTCVideo == null) {
            return;
        }

        VideoCanvas videoCanvas = new VideoCanvas(textureView, VideoCanvas.RENDER_MODE_HIDDEN);
        RemoteStreamKey streamKey = new RemoteStreamKey(roomId, uid, StreamIndex.STREAM_INDEX_MAIN);
        mRTCVideo.setRemoteVideoCanvas(streamKey, videoCanvas);
    }

    public void setLocalVideoCanvas(@Nullable TextureView textureView) {
        Log.d(TAG, "setLocalVideoCanvas: ");
        VideoCanvas videoCanvas = new VideoCanvas(textureView, VideoCanvas.RENDER_MODE_HIDDEN);
        mRTCVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
    }

    /**
     * 取消订阅指定用户的音频流
     *
     * @param uid 目标用户Uid
     */
    public void unsubscribeAudio(String uid) {
        Log.d(TAG, "unsubscribeAudio: " + uid);
        if (mRTCVideo == null || TextUtils.isEmpty(uid)) return;
        mUnsubscribeAudioUids.add(uid);
        if (mRTCRoom != null) {
            mRTCRoom.unsubscribeStream(uid, MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
        }
    }

    public void restoreSubscribeAudio() {
        Log.d(TAG, "restoreSubscribeAudio: ");
        if (mRTCVideo == null || mRTCRoom == null) return;
        Iterator<String> iterator = mUnsubscribeAudioUids.iterator();
        while (iterator.hasNext()) {
            String uid = iterator.next();
            mRTCRoom.subscribeStream(uid, MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
            iterator.remove();
        }
    }

    private static final int RTC_PLAYER_ID = 0;

    /**
     * 转发特定用户音频
     *
     * @param remoteUid 被转发的目标用户uid
     */
    public void forwardAudio(String remoteUid) {
        if (mRTCVideo == null || TextUtils.isEmpty(remoteUid)) {
            return;
        }
        IMediaPlayer player = mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        assert player != null;
        Log.d(TAG, "forwardAudio: enableAudioFrameCallback: " + remoteUid);
        mAudioFrameObserver = new ForwardAudioFrameObserver(remoteUid, player);
        mRTCVideo.enableAudioFrameCallback(AUDIO_FRAME_CALLBACK_REMOTE_USER,
                new AudioFormat(AudioSampleRate.AUDIO_SAMPLE_RATE_AUTO, AudioChannel.AUDIO_CHANNEL_AUTO));
        mRTCVideo.registerAudioFrameObserver(mAudioFrameObserver);
    }

    /**
     * 停止转发音频
     */
    public void stopForwardAudio() {
        if (mRTCVideo == null) {
            return;
        }
        ForwardAudioFrameObserver observer = mAudioFrameObserver;
        mAudioFrameObserver = null;
        if (observer != null) {
            Log.d(TAG, "stopForwardAudio: disableAudioFrameCallback: " + observer.remoteUid());
            mRTCVideo.disableAudioFrameCallback(AUDIO_FRAME_CALLBACK_REMOTE_USER);
            mRTCVideo.registerAudioFrameObserver(null);
        }
    }

    public boolean canOpenEarMonitor() {
        AudioRoute audioRoute = mRTCVideo.getAudioRoute();
        return AudioRouteChangedEvent.canOpenEarMonitor(audioRoute);
    }

    @NonNull
    private ChorusInfo mChorusInfo = ChorusInfo.empty;

    public void setChorusInfo(@NonNull ChorusInfo info) {
        mChorusInfo = info;
    }

    public void clearChorusInfo() {
        mChorusInfo = ChorusInfo.empty;
    }

    static void guard(@NonNull Runnable task) {
        try {
            task.run();
        } catch (Throwable t) {
            new Thread(() -> {
                throw t;
            }).start();
        }
    }
}
