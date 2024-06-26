// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.bytedance.chrous.R;
import com.ss.bytertc.engine.type.VoiceReverbType;
import com.vertcdemo.core.event.JoinRTSRoomErrorEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.utils.Streams;
import com.vertcdemo.solution.chorus.bean.FinishSingInform;
import com.vertcdemo.solution.chorus.bean.GetRequestSongResponse;
import com.vertcdemo.solution.chorus.bean.JoinRoomResponse;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.PickedSongInform;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.bean.SongItem;
import com.vertcdemo.solution.chorus.bean.StartSingInform;
import com.vertcdemo.solution.chorus.bean.StatusSongItem;
import com.vertcdemo.solution.chorus.bean.UserInfo;
import com.vertcdemo.solution.chorus.bean.WaitSingInform;
import com.vertcdemo.solution.chorus.common.SolutionToast;
import com.vertcdemo.solution.chorus.core.ChorusInfo;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.core.ChorusRTSClient;
import com.vertcdemo.solution.chorus.core.ErrorCodes;
import com.vertcdemo.solution.chorus.core.MusicDownloadManager;
import com.vertcdemo.solution.chorus.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.chorus.core.rts.annotation.SingType;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.event.DownloadStatusChanged;
import com.vertcdemo.solution.chorus.event.MusicLibraryInitEvent;
import com.vertcdemo.solution.chorus.event.PlayFinishEvent;
import com.vertcdemo.solution.chorus.event.UserVideoEvent;
import com.vertcdemo.solution.chorus.feature.room.bean.SingerData;
import com.vertcdemo.solution.chorus.feature.room.state.CaptureControl;
import com.vertcdemo.solution.chorus.feature.room.state.SingState;
import com.vertcdemo.solution.chorus.feature.room.state.SingerRole;
import com.vertcdemo.solution.chorus.feature.room.state.Singing;
import com.vertcdemo.solution.chorus.feature.room.state.UserRoleState;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class ChorusRoomViewModel extends ViewModel {
    private static final String TAG = "RoomViewModel";

    // region Room Info & User Info
    private RoomInfo roomInfo;
    private UserInfo myInfo;

    private boolean isHost;

    public String myUserId() {
        assert myInfo != null;
        return myInfo.userId;
    }

    public String hostUserId() {
        assert roomInfo != null;
        return roomInfo.hostUserId;
    }

    @NonNull
    public String requireRoomId() {
        RoomInfo info = Objects.requireNonNull(roomInfo, "No roomInfo present");
        return Objects.requireNonNull(info.roomId, "No roomId present");
    }

    public boolean isHost() {
        return isHost;
    }

    public void setIsHost(boolean value) {
        isHost = value;
        if (value) {
            captureControlMic.postValue(CaptureControl.ENABLED);
        }
    }

    public void setHostInfo(UserInfo host) {
        hostInfo.postValue(host);
    }

    public void setMyInfo(UserInfo userInfo) {
        myInfo = userInfo;
    }

    public UserInfo getMyInfo() {
        return myInfo;
    }

    public boolean isHost(String userId) {
        if (roomInfo == null || myInfo == null) {
            return false;
        }
        return TextUtils.equals(userId, roomInfo.hostUserId);
    }

    public final MutableLiveData<UserRoleState> userRoleState = new MutableLiveData<>(UserRoleState.NORMAL);

    public final MutableLiveData<CaptureControl> captureControlCamera = new MutableLiveData<>(CaptureControl.GONE);
    public final MutableLiveData<CaptureControl> captureControlMic = new MutableLiveData<>(CaptureControl.GONE);

    public final MutableLiveData<SingerRole> singerRole = new MutableLiveData<>(SingerRole.NONE);
    public final MutableLiveData<SingerData> leaderSinger = new MutableLiveData<>(SingerData.empty);
    public final MutableLiveData<SingerData> supportingSinger = new MutableLiveData<>(SingerData.empty);

    public void setRoomInfo(@NonNull RoomInfo roomInfo) {
        this.roomInfo = roomInfo;
        roomName.postValue(roomInfo.roomName);
        setBackground(roomInfo.getBackgroundKey());
        audienceCount.postValue(roomInfo.audienceCount);
    }

    public final MutableLiveData<Integer> audienceCount = new MutableLiveData<>();

    public final MutableLiveData<String> roomName = new MutableLiveData<>();

    public final MutableLiveData<Integer> background = new MutableLiveData<>();

    public final MutableLiveData<UserInfo> hostInfo = new MutableLiveData<>();

    public final MutableLiveData<Boolean> selfMicOn = new MutableLiveData<>(false);
    public final MutableLiveData<Boolean> selfCameraOn = new MutableLiveData<>(false);

    public void setBackground(@Nullable String backgroundKey) {
        if (backgroundKey == null) {
            return;
        }

        if (backgroundKey.startsWith("chorus_background_1")) {
            background.postValue(R.mipmap.chorus_background_1);
        } else if (backgroundKey.startsWith("chorus_background_2")) {
            background.postValue(R.mipmap.chorus_background_2);
        } else {
            background.postValue(R.mipmap.chorus_background_0);
        }
    }

    public void hostJoinRTCRoom(String rtcToken) {
        userRoleState.postValue(UserRoleState.HOST);

        if (TextUtils.isEmpty(rtcToken)) {
            Log.d(TAG, "No token provided, skip join Room");
        } else {
            ChorusRTCManager.ins().joinRoom(roomInfo.roomId, myUserId(), rtcToken);
        }

        requestAllSongs(roomInfo.roomId);

        // Host join room, set audio capture ON
        if (myInfo.isMicOn()) {
            startAudioCapture();
        } else {
            stopAudioCapture();
        }
    }

    public void requestJoinLiveRoom(String roomId) {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        rtsClient.requestJoinRoom(roomId, new IRequestCallback<JoinRoomResponse>() {
            @Override
            public void onSuccess(JoinRoomResponse data) {
                if (data == null || !data.isValid()) {
                    onError(-1, "Invalid JoinRoom response");
                    return;
                }

                handleJoinRoomResponse(data, false);
            }

            @Override
            public void onError(int errorCode, @Nullable String message) {
                SolutionEventBus.post(new JoinRTSRoomErrorEvent(errorCode, message));
            }
        });
    }

    void audienceJoinRTCRoom(String rtcToken) {
        if (TextUtils.isEmpty(rtcToken)) {
            Log.d(TAG, "No token provided, skip join Room");
        } else {
            ChorusRTCManager.ins().joinRoom(roomInfo.roomId, myUserId(), rtcToken);
        }

        selfMicOn.postValue(false);
    }


    public boolean isLeaderSinger() {
        SingerData singer = leaderSinger.getValue();
        return singer != null && myUserId().equals(singer.getUserId());
    }

    public boolean isSupportingSinger() {
        SingerData singer = supportingSinger.getValue();
        return singer != null && myUserId().equals(singer.getUserId());
    }

    private void setSingers(@Nullable UserInfo leader, @Nullable UserInfo supporting) {
        leaderSinger.postValue(SingerData.create(leader));
        supportingSinger.postValue(SingerData.create(supporting));

        ChorusRTCManager.ins().setChorusInfo(new ChorusInfo(
                myUserId(),
                leader == null ? null : leader.userId,
                supporting == null ? null : supporting.userId
        ));

        boolean isLeader = (leader != null && myUserId().equals(leader.userId));
        boolean isSupporting = (supporting != null && myUserId().equals(supporting.userId));

        if (isLeader) {
            singerRole.postValue(SingerRole.LEADER);
        } else if (isSupporting) {
            singerRole.postValue(SingerRole.SUPPORTING);
        } else {
            singerRole.postValue(SingerRole.NONE);
        }

        if (isLeader || isSupporting) {
            captureControlCamera.postValue(CaptureControl.ENABLED);

            // Force audio capture on, user should not be turned off
            captureControlMic.postValue(CaptureControl.DISABLED);
        } else {
            captureControlCamera.postValue(CaptureControl.GONE);

            if (isHost) {
                captureControlMic.postValue(CaptureControl.ENABLED);
            } else {
                captureControlMic.postValue(CaptureControl.GONE);
            }
        }
    }


    public void reconnectRoom() {
        String roomId = requireRoomId();
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        rtsClient.reconnectToServer(roomId, new IRequestCallback<JoinRoomResponse>() {
            @Override
            public void onSuccess(JoinRoomResponse data) {
                if (data == null || !data.isValid()) {
                    onError(-1, "Invalid JoinRoom response");
                    return;
                }
                handleJoinRoomResponse(data, true);
            }

            @Override
            public void onError(int errorCode, @Nullable String message) {
                SolutionEventBus.post(new JoinRTSRoomErrorEvent(errorCode, message, true));
            }
        });
    }

    void handleJoinRoomResponse(@NonNull JoinRoomResponse data, boolean reconnect) {
        setRoomInfo(Objects.requireNonNull(data.roomInfo));

        setHostInfo(Objects.requireNonNull(data.hostInfo));
        setMyInfo(Objects.requireNonNull(data.userInfo));

        setSingers(data.leaderSinger, data.supportingSinger);

        requestAllSongs(roomInfo.roomId);

        PickedSongInfo song = data.current;
        if (song == null) {
            singing.postValue(Singing.IDLE);
        } else if (song.status == SongStatus.WAITING) {
            singing.postValue(Singing.waitJoin(song));
        } else if (song.status == SongStatus.SINGING) {
            singing.postValue(Singing.singing(song));
        } else if (song.status == SongStatus.FINISH) {
            if (data.next != null) {
                singing.postValue(Singing.waitNext(data.next));
            } else {
                singing.postValue(Singing.EMPTY);
            }
        } else {
            singing.postValue(Singing.IDLE);
        }

        if (!reconnect) {
            audienceJoinRTCRoom(data.rtcToken);

            if (song != null
                    && song.status == SongStatus.SINGING
                    && (data.supportingSinger != null && !TextUtils.isEmpty(data.supportingSinger.userId))) {
                // is Chorus singing, we need unsubscribe leader's audio
                String leaderUid = Objects.requireNonNull(data.leaderSinger.userId);
                ChorusRTCManager.ins().unsubscribeAudio(leaderUid);
            }
        }
    }
    // endregion

    // region Song
    public final MutableLiveData<Singing> singing = new MutableLiveData<>(Singing.IDLE);

    public final MutableLiveData<List<StatusSongItem>> songLibrary = new MutableLiveData<>(Collections.emptyList());

    public final MutableLiveData<List<PickedSongInfo>> pickedSongs = new MutableLiveData<>(Collections.emptyList());

    @NonNull
    protected Map<String, SongItem> mSongItemMap = new HashMap<>();

    @Nullable
    public SongItem getSongItem(String songId) {
        return mSongItemMap.get(songId);
    }

    public void requestAllSongs(String roomId) {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        rtsClient.requestPresetSongList(roomId, data -> {
            List<StatusSongItem> songs = Streams.map(data.getSongs(), item -> {
                mSongItemMap.put(item.songId, item);
                return new StatusSongItem(item);
            });

            songLibrary.postValue(songs);

            requestPickedSongList(requireRoomId());

            SolutionEventBus.post(new MusicLibraryInitEvent());
        });
    }

    public void requestPickedSongList(String roomId) {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        rtsClient.requestPickedSongList(roomId, new IRequestCallback<GetRequestSongResponse>() {
            @Override
            public void onSuccess(GetRequestSongResponse data) {
                List<PickedSongInfo> list = data == null ? Collections.emptyList() : data.songList;
                pickedSongs.postValue(list);

                List<StatusSongItem> songs = songLibrary.getValue();
                if (songs != null && !songs.isEmpty()) {
                    Set<String> pickedByMe = Streams.mapToSet(list,
                            item -> TextUtils.equals(item.ownerUid, myUserId()),
                            item -> item.songId);

                    List<StatusSongItem> newSongs =
                            Streams.map(songs, item -> {
                                        if (pickedByMe.contains(item.getSongId())) {
                                            return item.copy(SongStatus.PICKED);
                                        } else if (item.status == SongStatus.PICKED) {
                                            return item.copy(SongStatus.FINISH);
                                        } else {
                                            return item;
                                        }
                                    }
                            );

                    songLibrary.postValue(newSongs);
                }
            }

            @Override
            public void onError(int errorCode, String message) {
                //ignore
            }
        });
    }

    public void onDownloadStatusChanged(DownloadStatusChanged event) {
        if (event.type == DownloadType.MUSIC
                && event.status == SongStatus.DOWNLOADING) {
            // Only handle Downloading Status
            updateStatusSongItem(event.songId, event.status);
        }

        if (event.contains(requireRoomId()) && event.status == SongStatus.DOWNLOADED) {
            if (event.type == DownloadType.MUSIC) {
                onMusicDownloaded(event.songId);
            }
        }
    }

    private void onMusicDownloaded(String songId) {
        requestSong(songId);
    }

    public void requestSong(String songId) {
        SongItem item = mSongItemMap.get(songId);
        if (item == null) {
            Log.d(TAG, "requestSong: SongItem not found");
            return;
        }

        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        String roomId = requireRoomId();
        rtsClient.requestSong(roomId,
                myUserId(),
                item.songId,
                item.songName,
                item.duration,
                item.coverUrl,
                new IRequestCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        Log.e(TAG, "requestSong: You picked a song: " + item.songName);
                    }

                    @Override
                    public void onError(int errorCode, @Nullable String message) {
                        Log.e(TAG, "requestSong: errorCode=" + errorCode + "; message=" + message);
                        SolutionToast.show(ErrorCodes.prettyMessage(errorCode, message));
                    }
                });
    }

    public void downloadTrack(String songId) {
        SongItem item = mSongItemMap.get(songId);
        if (item == null) {
            Log.d(TAG, "downloadTrack: SongItem not found");
            return;
        }
        MusicDownloadManager.ins().download(songId, requireRoomId(), item.songFileUrl, item.songLrcUrl);
    }

    public void downloadSongLrc(String songId) {
        SongItem item = mSongItemMap.get(songId);
        if (item == null) {
            Log.d(TAG, "downloadTrack: SongItem not found");
            return;
        }
        MusicDownloadManager.ins().downloadLrc(songId, requireRoomId(), item.songLrcUrl);
    }

    @Nullable
    public PickedSongInfo getCurrentSong() {
        Singing value = singing.getValue();
        assert value != null;
        return (value.state == SingState.SINGING) ? value.song : null;
    }

    public int currentDuration() {
        Singing value = singing.getValue();
        if (value == null) {
            return 0;
        }
        PickedSongInfo song = value.song;
        return song == null ? 0 : song.duration;
    }

    private void updateStatusSongItem(String songId, @SongStatus int status) {
        List<StatusSongItem> old = songLibrary.getValue();
        if (old == null || old.isEmpty()) {
            return;
        }

        List<StatusSongItem> songs = Streams.map(old,
                item -> TextUtils.equals(item.getSongId(), songId) ? item.copy(status) : item
        );

        songLibrary.postValue(songs);
    }

    public void startSing() {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;

        Singing status = Objects.requireNonNull(singing.getValue());
        if (status.state != SingState.WAITING_JOIN) {
            Log.e(TAG, "Error state: state is NOT WAITING: " + status.state);
            return;
        }

        PickedSongInfo song = Objects.requireNonNull(status.song);
        String type = isLeaderSinger() ? SingType.SOLO : SingType.CHORUS;
        rtsClient.startSing(requireRoomId(), song.songId, type);
    }

    private void doStartSinging(StartSingInform event) {
        UserInfo leader = event.leader;
        UserInfo supporting = event.supporting;
        PickedSongInfo song = event.song;

        boolean isChorus = supporting != null && !TextUtils.isEmpty(supporting.userId);
        if (isChorus) {
            // Duet
            if (TextUtils.equals(leader.userId, myUserId())) {
                // Leader Singer
                Log.d(TAG, "doStartSinging: Duet as leader Singer");
                initAudioEffectPresetLeader(true);
                startAudioCapture();

                ChorusRTCManager.ins().unsubscribeAudio(supporting.userId);
                tryAudioMixing(song);
            } else if (TextUtils.equals(myUserId(), supporting.userId)) {
                Log.d(TAG, "doStartSinging: Duet as Supporting Singer");

                // Supporting Singer
                initAudioEffectPresetSupporting();
                startAudioCapture();

                ChorusRTCManager.ins().forwardAudio(leader.userId);
            } else {
                Log.d(TAG, "doStartSinging: Duet as Audience");
                ChorusRTCManager.ins().unsubscribeAudio(leader.userId);
            }
        } else {
            // Solo
            if (TextUtils.equals(leader.userId, myUserId())) {
                // Leader Singer
                Log.d(TAG, "doStartSinging: Solo as leader Singer");
                initAudioEffectPresetLeader(false);
                startAudioCapture();

                tryAudioMixing(song);
            } else {
                Log.d(TAG, "doStartSinging: Solo as Audience");
            }
        }
    }

    private void tryAudioMixing(@NonNull PickedSongInfo song) {
        Log.d(TAG, "tryAudioMixing: song.name='" + song.songName + "'");
        File file = MusicDownloadManager.mp3File(song.songId);
        assert file.exists();
        boolean accompany = true; // default to accompany mode, user can switch to origin
        originTrack.postValue(!accompany);
        ChorusRTCManager.ins().startAudioMixing(song.songId, file.getAbsolutePath(), musicVolume, accompany);
    }


    public void finishSinging(String from) {
        Log.d(TAG, "Finish Singing, reset RTC status: from=" + from);
        if (!isHost()) { // Stop normal singers' capture, except HOST user
            stopAudioCapture();
        }

        stopVideoCapture();

        if (isLeaderSinger()) {
            Log.d(TAG, "I am leader singer, stopAudioMixing");
            ChorusRTCManager.ins().stopAudioMixing();

            resetEarMonitorStatus();
            if (isHost()) {
                // restore HOST audio effect to origin
                setAudioEffect(VoiceReverbType.VOICE_REVERB_ORIGINAL);
            }
        } else if (isSupportingSinger()) {
            Log.d(TAG, "I am supporting singer, stopForwardAudio");
            ChorusRTCManager.ins().stopForwardAudio();

            resetEarMonitorStatus();
            if (isHost()) {
                // restore HOST audio effect to origin
                setAudioEffect(VoiceReverbType.VOICE_REVERB_ORIGINAL);
            }

            // Should restore Music volume to 100,
            // or else will caused the supporting user can't hear current leader user's voice
            setMusicVolume(100);
        }

        // All user need restore subscribe status
        ChorusRTCManager.ins().restoreSubscribeAudio();
        ChorusRTCManager.ins().clearChorusInfo();
    }
    // endregion


    // region Events
    public void onPickSongInform(PickedSongInform event) {
        boolean pickedBySelf = TextUtils.equals(myUserId(), event.song.ownerUid);
        if (!pickedBySelf) {
            downloadSongLrc(event.song.songId);
        }
        requestPickedSongList(requireRoomId());
    }

    public void onWaitSingInform(WaitSingInform event) {
        Singing current = Objects.requireNonNull(singing.getValue());
        if (current.state == SingState.SINGING) {
            // User cutSong manually, So we need finish current
            finishSinging("WaitSingInform");
        }

        requestPickedSongList(requireRoomId());

        setSingers(event.leader, null);
        Singing next = event.song == null ? Singing.EMPTY : Singing.waitJoin(event.song);
        singing.postValue(next);
    }

    public void onStartSingInform(StartSingInform event) {
        setSingers(event.leader, event.supporting);
        singing.postValue(Singing.singing(Objects.requireNonNull(event.song)));
        doStartSinging(event);
    }

    public void onPlayFinishEvent(PlayFinishEvent event) {
        Log.d(TAG, "onPlayFinishEvent: ");
        PickedSongInfo song = getCurrentSong();
        if (song != null && TextUtils.equals(song.songId, event.songId)) {
            ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
            assert rtsClient != null;
            rtsClient.finishSing(requireRoomId(), event.songId, 100);
        } else {
            Log.d(TAG, "onPlayFinishEvent: songId mismatch!!!");
        }
    }

    public void onFinishSingInform(FinishSingInform event) {
        requestPickedSongList(requireRoomId());

        if (event.nextSong == null) {
            singing.postValue(Singing.EMPTY);
        } else {
            setSingers(null, null);
            singing.postValue(Singing.waitNext(event.nextSong));
        }
    }

    public void onUserVideoEvent(UserVideoEvent event) {
        { // leaderSinger
            SingerData value = leaderSinger.getValue();
            if (value != null) {
                if (TextUtils.equals(event.uid, value.getUserId())) {
                    leaderSinger.postValue(value.copy(event.hasVideo));
                    return;
                }
            }
        }

        { // supportingSinger
            SingerData value = supportingSinger.getValue();
            if (value != null) {
                if (TextUtils.equals(event.uid, value.getUserId())) {
                    supportingSinger.postValue(value.copy(event.hasVideo));
                    return;
                }
            }
        }

        Log.w(TAG, "onUserVideoEvent: Someone not singer: " + event);
    }
    // endregion

    // region Controls
    private void initAudioEffectPresetLeader(boolean isChorus) {
        setAudioEffect(VoiceReverbType.VOICE_REVERB_KTV);
        setMusicVolume(10);
        setVocalVolume(100);
    }

    private void initAudioEffectPresetSupporting() {
        setAudioEffect(VoiceReverbType.VOICE_REVERB_KTV);
        setMusicVolume(100);
        setVocalVolume(100);
    }

    public final MutableLiveData<Boolean> earMonitorSwitch = new MutableLiveData<>(false);
    public final MutableLiveData<Boolean> originTrack = new MutableLiveData<>(false);

    private VoiceReverbType voiceReverbType = VoiceReverbType.VOICE_REVERB_ORIGINAL;
    @IntRange(from = 0, to = 100)
    private int musicVolume = 10;
    @IntRange(from = 0, to = 100)
    private int vocalVolume = 100;
    @IntRange(from = 0, to = 100)
    private int earMonitorVolume = 100;

    public void setAudioEffect(VoiceReverbType value) {
        voiceReverbType = value;
        ChorusRTCManager.ins().setAudioEffect(value);
    }

    public void setEarMonitorSwitch(boolean value) {
        earMonitorSwitch.postValue(value);
        if (value) {
            ChorusRTCManager.ins().openEarMonitor();
        } else {
            ChorusRTCManager.ins().closeEarMonitor();
        }
    }

    public void setEarMonitorVolume(int value) {
        earMonitorVolume = value;
        ChorusRTCManager.ins().adjustEarMonitorVolume(value);
    }

    public void setMusicVolume(int value) {
        musicVolume = value;
        ChorusRTCManager.ins().adjustSongVolume(value, isLeaderSinger());
    }

    public void setVocalVolume(int value) {
        vocalVolume = value;
        ChorusRTCManager.ins().adjustUserVolume(value);
    }

    public int getEarMonitorVolume() {
        return earMonitorVolume;
    }

    private void resetEarMonitorStatus() {
        setEarMonitorSwitch(false);
        setEarMonitorVolume(100);
    }

    public int getMusicVolume() {
        return musicVolume;
    }

    public int getVocalVolume() {
        return vocalVolume;
    }

    public VoiceReverbType getVoiceReverbType() {
        return voiceReverbType;
    }

    public void switchTrack() {
        boolean playAccompany = ChorusRTCManager.ins().toggleAudioAccompanyMode();
        if (playAccompany) {
            SolutionToast.show(R.string.toast_backing_track_enabled);
            originTrack.postValue(false);
        } else {
            SolutionToast.show(R.string.toast_original_vocals_enabled);
            originTrack.postValue(true);
        }
    }

    public void nextTrack() {
        nextTrack(false);
    }

    /**
     * Switch to next song
     *
     * @param force force is true, means no need to check owner
     */
    public void nextTrack(boolean force) {
        Log.d(TAG, "nextTrack: force=" + force);
        if (!force) {
            PickedSongInfo curSingSong = getCurrentSong();
            if (curSingSong == null) {
                Log.d(TAG, "nextTrack: curSingSong is null");
                return;
            }
            boolean pickedBySelf = TextUtils.equals(curSingSong.ownerUid, myUserId());
            if (!pickedBySelf) {
                Log.d(TAG, "nextTrack: isOwner=false");
                return;
            }
        }

        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null;
        rtsClient.cutOffSong(requireRoomId(), myUserId(), new IRequestCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                // Success, Wait 'OnStartSing' notify event
                Log.d(TAG, "nextTrack: onSuccess");
            }

            @Override
            public void onError(int errorCode, String message) {
                SolutionToast.show(R.string.toast_cut_off_failed, Toast.LENGTH_SHORT);
            }
        });
    }

    public void toggleCamera() {
        boolean current = selfCameraOn.getValue() == Boolean.TRUE;

        if (current) {
            stopVideoCapture();
        } else {
            startVideoCapture();
        }
    }

    public void startVideoCapture() {
        selfCameraOn.postValue(true);
        ChorusRTCManager.ins().startVideoCapture();
    }

    public void stopVideoCapture() {
        selfCameraOn.postValue(false);
        ChorusRTCManager.ins().stopVideoCapture();
    }

    public void toggleMic() {
        boolean current = selfMicOn.getValue() == Boolean.TRUE;
        if (current) {
            stopAudioCapture();
        } else {
            startAudioCapture();
        }
    }

    public void startAudioCapture() {
        selfMicOn.postValue(true);
        ChorusRTCManager.ins().startAudioCapture();
    }

    public void stopAudioCapture() {
        selfMicOn.postValue(false);
        ChorusRTCManager.ins().stopAudioCapture();
    }
    // endregion
}
