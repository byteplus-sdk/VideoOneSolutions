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
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.IMediaPlayerEventHandler;
import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.audio.IMediaPlayer;
import com.ss.bytertc.engine.data.AudioPropertiesConfig;
import com.ss.bytertc.engine.data.AudioRoute;
import com.ss.bytertc.engine.data.EarMonitorMode;
import com.ss.bytertc.engine.data.LocalAudioPropertiesInfo;
import com.ss.bytertc.engine.data.MediaPlayerConfig;
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
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.event.AudioRouteChangedEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.rtc.IRTCManager;
import com.vertcdemo.core.rts.RTCRoomEventHandlerWithRTS;
import com.vertcdemo.core.rts.RTCVideoEventHandlerWithRTS;
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

public class KTVRTCManager implements IRTCManager {

    private static final String TAG = "KTVRTCManager";
    private static KTVRTCManager sInstance;
    private RTCVideo mRTCVideo;
    private RTCRoom mRTCRoom;
    private final KTVRTSClient mRTSClient = new KTVRTSClient();
    private volatile String mCurrentMusicId; // 当前混音音乐id

    public interface SongPlayProgressCallback {
        @MainThread
        void notifyProgress(@NonNull String musicId, long progress);
    }

    private SongPlayProgressCallback mProgressCallback;

    private final RTCVideoEventHandlerWithRTS mRTCVideoEventHandler = new RTCVideoEventHandlerWithRTS(mRTSClient) {

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

    private boolean isEnableAudioCapture = false;

    private final RTCRoomEventHandlerWithRTS mRTCRoomEventHandler = new RTCRoomEventHandlerWithRTS(mRTSClient, true) {

        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            Log.d(TAG, String.format("onRoomStateChanged: roomId=%s, uid=%s, state=%d, extra=%s", roomId, uid, state, extraInfo));
        }

        @Override
        public void onNetworkQuality(NetworkQualityStats localQuality, NetworkQualityStats[] remoteQualities) {
            if (isEnableAudioCapture) {
                notifyLocalRTTUpdated(localQuality.rtt);
            } else {
                if (remoteQualities.length > 0) {
                    notifyLocalRTTUpdated(remoteQualities[0].rtt);
                } else {
                    notifyLocalRTTUpdated(0);
                }
            }
        }

        private void notifyLocalRTTUpdated(int rtt) {
            AudioStatsEvent event = new AudioStatsEvent(rtt);
            SolutionEventBus.post(event);
        }
    };

    private KTVRTCManager() {
        Log.d(TAG, "RTCVideo sdkVersion: " + RTCVideo.getSDKVersion());
    }

    public synchronized static KTVRTCManager ins() {
        if (sInstance == null) {
            sInstance = new KTVRTCManager();
        }
        return sInstance;
    }

    public void setProgressCallback(SongPlayProgressCallback cb) {
        mProgressCallback = cb;
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

        AudioPropertiesConfig config = new AudioPropertiesConfig(300);
        rtcVideo.enableAudioPropertiesReport(config);
        rtcVideo.setAudioScenario(AudioScenarioType.AUDIO_SCENARIO_MUSIC);
        rtcVideo.setAudioProfile(AudioProfileType.AUDIO_PROFILE_HD);

        mRTCVideo = rtcVideo;
    }

    @Override
    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");
        if (mRTCRoom != null) {
            mRTCRoom.destroy();
        }
        if (mRTCVideo != null) {
            RTCVideo.destroyRTCVideo();
            mRTCVideo = null;
        }
    }

    public void joinRoom(String roomId, String userId, String token) {
        Log.d(TAG, String.format("joinRoom: roomId=%s, userId=%s", roomId, userId));
        leaveRoom();
        if (mRTCVideo == null) {
            return;
        }
        mRTCRoom = mRTCVideo.createRTCRoom(roomId);
        mRTCRoom.setRTCRoomEventHandler(mRTCRoomEventHandler);
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
        isEnableAudioCapture = start;
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

    private static final int RTC_PLAYER_ID = 0;

    private final IMediaPlayerEventHandler mPlayerEventHandler = new IMediaPlayerEventHandler() {

        @Override
        public void onMediaPlayerStateChanged(int playerId, PlayerState state, PlayerError error) {
            Log.d(TAG, "onMediaPlayerStateChanged state:" + state + "; error: " + error);
            if (PlayerError.OK == error) {
                SolutionEventBus.post(AudioMixingStateEvent.of(state));
            }
        }

        @Override
        public void onMediaPlayerPlayingProgress(int playerId, long progress) {
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
    };

    public void startAudioMixing(String musicId, String musicLocalFileUri, int musicVolume, int vocalVolume) {
        Log.d(TAG, "startAudioMixing: " + musicLocalFileUri);
        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            Log.w(TAG, "startAudioMixing: player is null");
            return;
        }
        if (!TextUtils.isEmpty(musicLocalFileUri)) {
            mCurrentMusicId = musicId;
            //先停止
            player.stop();

            //再播放
            setAudioEffect(VoiceReverbType.VOICE_REVERB_KTV);
            adjustUserVolume(vocalVolume);

            MediaPlayerConfig config = new MediaPlayerConfig();
            config.type = AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH;
            config.playCount = 1;
            config.callbackOnProgressInterval = 100;
            config.autoPlay = true;

            player.setEventHandler(mPlayerEventHandler);
            player.open(musicLocalFileUri, config);
            player.setVolume(musicVolume, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);

            selectAudioTrack(isAccompanyMode = true);
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

        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            return;
        }
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
        Log.d(TAG, "selectAudioTrack: " + isAccompany);
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

    public void resetAudioMixingDualMonoMode() {
        isAccompanyMode = true;
        selectAudioTrack(true);
    }

    public boolean inAudioMixing;

    public void resumeAudioMixing() {
        Log.d(TAG, "resumeAudioMixing");
        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            return;
        }
        player.resume();
        inAudioMixing = true;
    }

    public void pauseAudioMixing() {
        Log.d(TAG, "pauseAudioMixing");
        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            return;
        }
        player.pause();
        inAudioMixing = false;
    }

    public void adjustSongVolume(@IntRange(from = 0, to = 400) int volume) {
        Log.d(TAG, "adjustSongVolume: " + volume);
        IMediaPlayer player = mRTCVideo == null ? null : mRTCVideo.getMediaPlayer(RTC_PLAYER_ID);
        if (player == null) {
            return;
        }
        player.setVolume(volume, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);
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
