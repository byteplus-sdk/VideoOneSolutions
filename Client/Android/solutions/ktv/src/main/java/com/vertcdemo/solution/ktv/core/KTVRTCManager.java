// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core;

import static com.ss.bytertc.engine.data.AudioMixingDualMonoMode.AUDIO_MIXING_DUAL_MONO_MODE_L;
import static com.ss.bytertc.engine.data.AudioMixingDualMonoMode.AUDIO_MIXING_DUAL_MONO_MODE_R;
import static com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH;

import android.app.Application;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.IntRange;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.audio.IAudioMixingManager;
import com.ss.bytertc.engine.data.AudioMixingConfig;
import com.ss.bytertc.engine.data.AudioMixingError;
import com.ss.bytertc.engine.data.AudioMixingState;
import com.ss.bytertc.engine.data.AudioPropertiesConfig;
import com.ss.bytertc.engine.data.AudioRoute;
import com.ss.bytertc.engine.data.EarMonitorMode;
import com.ss.bytertc.engine.data.LocalAudioPropertiesInfo;
import com.ss.bytertc.engine.data.RemoteAudioPropertiesInfo;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.StreamSycnInfoConfig;
import com.ss.bytertc.engine.type.AudioProfileType;
import com.ss.bytertc.engine.type.AudioScenarioType;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.LocalStreamStats;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RemoteStreamStats;
import com.ss.bytertc.engine.type.VoiceReverbType;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.event.AudioRouteChangedEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.rts.RTCRoomEventHandlerWithRTS;
import com.vertcdemo.core.net.rts.RTCVideoEventHandlerWithRTS;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.ktv.event.AudioMixingStateEvent;
import com.vertcdemo.solution.ktv.event.AudioStatsEvent;
import com.vertcdemo.solution.ktv.event.SDKAudioPropertiesEvent;

import org.json.JSONObject;
import org.json.JSONStringer;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class KTVRTCManager {

    private static final String TAG = "KTVRTCManager";
    private static KTVRTCManager sInstance;
    private RTCVideo mRTCVideo;
    private RTCRoom mRTCRoom;
    private KTVRTSClient mRTSClient;
    private volatile String mCurrentMusicId; // 当前混音音乐id

    public interface SongPlayProgressCallback {
        @MainThread
        void notifyProgress(@NonNull String musicId, long progress);
    }

    private SongPlayProgressCallback mProgressCallback;

    private final RTCVideoEventHandlerWithRTS mRTCVideoEventHandler = new RTCVideoEventHandlerWithRTS() {

        @Override
        public void onWarning(int warn) {
            Log.d(TAG, "onWarning: " + warn);
        }

        @Override
        public void onError(int err) {
            Log.d(TAG, "onError: " + err);
        }

        /**
         * 本地音频包括使用 RTC SDK 内部机制采集的麦克风音频和屏幕音频。
         * @param audioPropertiesInfos 本地音频信息，详见 LocalAudioPropertiesInfo 。
         */
        @Override
        public void onLocalAudioPropertiesReport(LocalAudioPropertiesInfo[] audioPropertiesInfos) {
            if (audioPropertiesInfos == null) {
                return;
            }
            for (LocalAudioPropertiesInfo info : audioPropertiesInfos) {
                if (info.streamIndex == StreamIndex.STREAM_INDEX_MAIN) {
                    SDKAudioPropertiesEvent.AudioProperties properties = new SDKAudioPropertiesEvent.AudioProperties(
                            SolutionDataManager.ins().getUserId(),
                            info.audioPropertiesInfo);
                    SolutionEventBus.post(new SDKAudioPropertiesEvent(properties));
                    return;
                }
            }
        }

        /**
         * 远端用户的音频包括使用 RTC SDK 内部机制/自定义机制采集的麦克风音频和屏幕音频。
         * @param audioPropertiesInfos 远端音频信息，其中包含音频流属性、房间 ID、用户 ID ，详见 RemoteAudioPropertiesInfo。
         * @param totalRemoteVolume 订阅的所有远端流的总音量。
         */
        @Override
        public void onRemoteAudioPropertiesReport(RemoteAudioPropertiesInfo[] audioPropertiesInfos, int totalRemoteVolume) {
            if (audioPropertiesInfos == null) {
                return;
            }
            List<SDKAudioPropertiesEvent.AudioProperties> audioPropertiesList = new ArrayList<>();
            for (RemoteAudioPropertiesInfo info : audioPropertiesInfos) {
                if (info.streamKey.getStreamIndex() == StreamIndex.STREAM_INDEX_MAIN) {
                    audioPropertiesList.add(new SDKAudioPropertiesEvent.AudioProperties(
                            info.streamKey.getUserId(),
                            info.audioPropertiesInfo));
                }
            }
            SolutionEventBus.post(new SDKAudioPropertiesEvent(audioPropertiesList));
        }

        /****
         * 本地播放状态回调
         */
        @Override
        public void onAudioMixingStateChanged(int id, AudioMixingState state, AudioMixingError error) {
            Log.d(TAG, "onAudioMixingStateChanged state:" + state + "; error: " + error);
            if (AudioMixingError.AUDIO_MIXING_ERROR_OK == error) {
                SolutionEventBus.post(new AudioMixingStateEvent(state));
            }
        }

        /****
         * 本地播放进度回调
         * @param id
         * @param progress
         */
        @Override
        public void onAudioMixingPlayingProgress(int id, long progress) {
            String musicId = mCurrentMusicId;
            if (musicId == null) {
                return;
            }
            syncProgressToRemote(musicId, progress);
            SongPlayProgressCallback callback = mProgressCallback;
            if (callback != null) {
                AppExecutors.mainThread().execute(() -> callback.notifyProgress(musicId, progress));
            }
        }

        /****
         * 远端播放进度广播通过此回调接收
         */
        @Override
        public void onStreamSyncInfoReceived(RemoteStreamKey streamKey,
                                             StreamSycnInfoConfig.SyncInfoStreamType streamType,
                                             ByteBuffer data) {
            SongPlayProgressCallback callback = mProgressCallback;
            if (callback == null) {
                return;
            }
            AppExecutors.mainThread().execute(() -> {
                CharsetDecoder decoder = StandardCharsets.UTF_8.newDecoder();
                try {
                    CharBuffer buffer = decoder.decode(data);

                    JSONObject jsonObject = new JSONObject(buffer.toString());
                    long progress = jsonObject.getLong("progress");
                    String musicId = jsonObject.getString("music_id");

                    callback.notifyProgress(musicId, progress);
                } catch (Exception e) {
                    Log.d(TAG, "onStreamSyncInfoReceived decode exception", e);
                }
            });
        }

        @Override
        public void onAudioRouteChanged(AudioRoute device) {
            Log.d(TAG, "onAudioRouteChanged device:" + device);
            SolutionEventBus.post(new AudioRouteChangedEvent(device));
        }
    };

    private final RTCRoomEventHandlerWithRTS mRTCRoomEventHandler = new RTCRoomEventHandlerWithRTS(true) {

        private float mRemoteAudioLossRate;

        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            Log.d(TAG, String.format("onRoomStateChanged: roomId=%s, uid=%s, state=%d, extra=%s", roomId, uid, state, extraInfo));
        }

        @Override
        public void onLocalStreamStats(LocalStreamStats stats) {
            AudioStatsEvent event = new AudioStatsEvent(stats.audioStats.rtt, stats.audioStats.audioLossRate, mRemoteAudioLossRate);
            SolutionEventBus.post(event);
        }

        @Override
        public void onRemoteStreamStats(RemoteStreamStats stats) {
            mRemoteAudioLossRate = stats.audioStats.audioLossRate;
        }
    };

    private KTVRTCManager() {
        Log.d(TAG, "RTCVideo sdkVersion: " + RTCVideo.getSDKVersion());
    }

    public static KTVRTCManager ins() {
        if (sInstance == null) {
            sInstance = new KTVRTCManager();
        }
        return sInstance;
    }

    public void setProgressCallback(SongPlayProgressCallback cb) {
        mProgressCallback = cb;
    }

    public void rtcConnect(RTSInfo rtsInfo) {
        Log.d(TAG, "rtcConnect: appId='" + rtsInfo.appId + "'; bid=" + rtsInfo.bid);
        destroyEngine();
        mRTCVideo = createRTCVideo(rtsInfo.appId, rtsInfo.bid);

        mRTSClient = new KTVRTSClient(mRTCVideo, rtsInfo);
        mRTCVideoEventHandler.setBaseClient(mRTSClient);
        mRTCRoomEventHandler.setBaseClient(mRTSClient);
    }

    private RTCVideo createRTCVideo(String appId, String bid) {
        final Application context = AppUtil.getApplicationContext();
        RTCVideo rtcVideo = RTCVideo.createRTCVideo(context, appId, mRTCVideoEventHandler, null, null);
        rtcVideo.setBusinessId(bid);
        rtcVideo.stopVideoCapture();

        AudioPropertiesConfig config = new AudioPropertiesConfig(300);
        rtcVideo.enableAudioPropertiesReport(config);
        rtcVideo.setAudioScenario(AudioScenarioType.AUDIO_SCENARIO_MUSIC);
        rtcVideo.setAudioProfile(AudioProfileType.AUDIO_PROFILE_HD);

        return rtcVideo;
    }

    public KTVRTSClient getRTSClient() {
        return mRTSClient;
    }

    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");
        if (mRTCRoom != null) {
            mRTCRoom.destroy();
        }
        if (mRTCVideo != null) {
            RTCVideo.destroyRTCVideo();
            mRTCVideo = null;
        }
        mRTSClient = null;
    }

    public void joinRoom(String roomId, String userId, String token) {
        Log.d(TAG, String.format("joinRoom: roomId=%s, userId=%s", roomId, userId));
        leaveRoom();
        if (mRTCVideo == null) {
            return;
        }
        mRTCRoom = mRTCVideo.createRTCRoom(roomId);
        mRTCRoom.setRTCRoomEventHandler(mRTCRoomEventHandler);
        mRTCRoomEventHandler.setBaseClient(mRTSClient);
        UserInfo userInfo = new UserInfo(userId, null);
        RTCRoomConfig roomConfig = new RTCRoomConfig(
                ChannelProfile.CHANNEL_PROFILE_KTV,
                false,
                true,
                false);
        mRTCRoom.setUserVisibility(false);
        mRTCRoom.joinRoom(token, userInfo, roomConfig);
    }

    public void leaveRoom() {
        Log.d(TAG, "leaveRoom");
        if (mRTCRoom != null) {
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
        }
    }

    public void setUserVisibility(boolean visible) {
        Log.d(TAG, "setUserVisibility: " + visible);
        if (mRTCRoom != null) {
            mRTCRoom.setUserVisibility(visible);
        }
    }

    public void startAudioCapture(boolean start) {
        Log.d(TAG, "startAudioCapture: " + start);
        if (mRTCVideo == null) {
            return;
        }
        if (start) {
            mRTCVideo.startAudioCapture();
        } else {
            mRTCVideo.stopAudioCapture();
        }
    }

    public void startAudioPublish(boolean publish) {
        Log.d(TAG, "startAudioPublish: " + publish);
        if (mRTCRoom == null) {
            return;
        }

        if (publish) {
            mRTCRoom.publishStream(MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
        } else {
            mRTCRoom.unpublishStream(MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
        }
    }

    private static final int AUDIO_MIXING_ID = 0;

    public void startAudioMixing(String musicId, String musicLocalFileUri, int musicVolume, int vocalVolume) {
        Log.d(TAG, "startAudioMixing: " + musicLocalFileUri);
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        if (!TextUtils.isEmpty(musicLocalFileUri)) {
            mCurrentMusicId = musicId;
            //先停止
            audioMixingManager.stopAudioMixing(AUDIO_MIXING_ID);
            //再播放
            setAudioEffect(VoiceReverbType.VOICE_REVERB_KTV);
            AudioMixingConfig config = new AudioMixingConfig(AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH, 1);
            audioMixingManager.startAudioMixing(AUDIO_MIXING_ID, musicLocalFileUri, config);
            adjustSongVolume(musicVolume);
            adjustUserVolume(vocalVolume);
            selectAudioTrack(isAccompanyMode = true);
            audioMixingManager.setAudioMixingProgressInterval(AUDIO_MIXING_ID, 100);
            inAudioMixing = true;
        } else {
            stopAudioMixing();
        }
    }

    /**
     * 停止混音
     */
    public void stopAudioMixing() {
        Log.d(TAG, "stopAudioMixing");
        setAudioEffect(VoiceReverbType.VOICE_REVERB_ORIGINAL);

        mCurrentMusicId = null;
        inAudioMixing = false;
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        audioMixingManager.stopAudioMixing(AUDIO_MIXING_ID);
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
        Log.d(TAG, "toggleAudioAccompanyMode");
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        int trackCount = audioMixingManager.getAudioTrackCount(AUDIO_MIXING_ID);
        if (trackCount >= 2) {
            // Select Origin/Accompany use track
            if (isAccompany) {
                audioMixingManager.selectAudioTrack(AUDIO_MIXING_ID, 1);
            } else {
                audioMixingManager.selectAudioTrack(AUDIO_MIXING_ID, 2);
            }
        } else {
            // Select Origin/Accompany use L/R
            if (isAccompany) {
                audioMixingManager.setAudioMixingDualMonoMode(AUDIO_MIXING_ID, AUDIO_MIXING_DUAL_MONO_MODE_R);
            } else {
                audioMixingManager.setAudioMixingDualMonoMode(AUDIO_MIXING_ID, AUDIO_MIXING_DUAL_MONO_MODE_L);
            }
        }
    }

    public void resetAudioMixingDualMonoMode() {
        isAccompanyMode = true;
        selectAudioTrack(true);
    }

    public boolean inAudioMixing;

    public void resumeAudioMixing() {
        Log.d(TAG, "resumeAudioMixing");
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        audioMixingManager.resumeAudioMixing(AUDIO_MIXING_ID);
        inAudioMixing = true;
    }

    public void pauseAudioMixing() {
        Log.d(TAG, "pauseAudioMixing");
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        audioMixingManager.pauseAudioMixing(AUDIO_MIXING_ID);
        inAudioMixing = false;
    }

    public void adjustSongVolume(@IntRange(from = 0, to = 400) int volume) {
        Log.d(TAG, "adjustSongVolume: " + volume);
        IAudioMixingManager audioMixingManager = mRTCVideo == null ? null : mRTCVideo.getAudioMixingManager();
        if (audioMixingManager == null) {
            return;
        }
        audioMixingManager.setAudioMixingVolume(AUDIO_MIXING_ID, volume, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);
    }

    public void adjustUserVolume(@IntRange(from = 0, to = 400) int volume) {
        Log.d(TAG, "adjustUserVolume: " + volume);
        if (mRTCVideo != null) {
            mRTCVideo.setCaptureVolume(StreamIndex.STREAM_INDEX_MAIN, volume);
        }
    }

    public void adjustEarMonitorVolume(int progress) {
        if (mRTCVideo != null && earMonitorOpening) {
            mRTCVideo.setEarMonitorVolume(progress);
        }
    }

    private boolean earMonitorOpening;

    public void openEarMonitor(int volume) {
        if (mRTCVideo != null) {
            mRTCVideo.setEarMonitorMode(EarMonitorMode.EAR_MONITOR_MODE_ON);
        }
        earMonitorOpening = true;
        adjustEarMonitorVolume(volume);
    }

    public boolean canOpenEarMonitor() {
        AudioRoute audioRoute = mRTCVideo.getAudioRoute();
        return AudioRouteChangedEvent.canOpenEarMonitor(audioRoute);
    }

    public void closeEarMonitor() {
        if (mRTCVideo != null) {
            mRTCVideo.setEarMonitorMode(EarMonitorMode.EAR_MONITOR_MODE_OFF);
        }
        earMonitorOpening = false;
    }

    public void setAudioEffect(VoiceReverbType type) {
        Log.d(TAG, "setAudioEffect=" + type);
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
    public void syncProgressToRemote(@NonNull String musicId, long progress) {
        if (mRTCVideo != null) {
            StreamSycnInfoConfig config = new StreamSycnInfoConfig(
                    StreamIndex.STREAM_INDEX_MAIN,
                    3,
                    StreamSycnInfoConfig.SyncInfoStreamType.SYNC_INFO_STREAM_TYPE_AUDIO);

            try {
                JSONStringer json =
                        new JSONStringer().object()
                                .key("music_id").value(musicId)
                                .key("progress").value(progress)
                                .endObject();

                mRTCVideo.sendStreamSyncInfo(json.toString().getBytes(), config);
            } catch (Exception e) {
                Log.d(TAG, "syncProgressToRemote exception: " + e.getMessage());
            }
        }
    }
}
