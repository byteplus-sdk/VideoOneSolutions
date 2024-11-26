// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.viewmodel;


import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.ss.bytertc.engine.type.VoiceReverbType;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.event.JoinRTSRoomErrorEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.callback.OnResponse;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.Streams;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.bean.SongItem;
import com.vertcdemo.solution.ktv.bean.StatusSongItem;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.Defaults;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.core.KTVRTCManager;
import com.vertcdemo.solution.ktv.core.MusicDownloadManager;
import com.vertcdemo.solution.ktv.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.ktv.core.rts.annotation.NeedApplyOption;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatOption;
import com.vertcdemo.solution.ktv.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserRole;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.event.DownloadStatusChanged;
import com.vertcdemo.solution.ktv.event.FinishSingBroadcast;
import com.vertcdemo.solution.ktv.event.InitSeatDataEvent;
import com.vertcdemo.solution.ktv.event.MusicLibraryInitEvent;
import com.vertcdemo.solution.ktv.event.RequestSongBroadcast;
import com.vertcdemo.solution.ktv.event.StartSingBroadcast;
import com.vertcdemo.solution.ktv.feature.main.state.SingState;
import com.vertcdemo.solution.ktv.feature.main.state.Singing;
import com.vertcdemo.solution.ktv.feature.main.state.UserRoleState;
import com.vertcdemo.solution.ktv.http.KTVService;
import com.vertcdemo.solution.ktv.http.response.ApplyInteractResponse;
import com.vertcdemo.solution.ktv.http.response.GetAudienceResponse;
import com.vertcdemo.solution.ktv.http.response.GetPickedSongListResponse;
import com.vertcdemo.solution.ktv.http.response.GetPresetSongListResponse;
import com.vertcdemo.solution.ktv.http.response.JoinRoomResponse;
import com.vertcdemo.ui.CenteredToast;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class KTVRoomViewModel extends ViewModel {

    private static final String TAG = "RoomViewModel";

    // region Room Info & User Info
    private RoomInfo roomInfo;
    private UserInfo myInfo;

    private boolean isHost;

    public String myUserId() {
        assert myInfo != null;
        return myInfo.userId;
    }

    public int myUserStatus() {
        assert myInfo != null;
        return myInfo.userStatus;
    }

    public void updateSelf(UserInfo userInfo) {
        myInfo.updateBy(userInfo);
        setSelfApply(false);

        updateUserRoleState(userInfo.userRole, userInfo.userStatus);
        selfMicOn.postValue(userInfo.isMicOn());
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
    }

    public void setRoomInfo(@NonNull RoomInfo roomInfo) {
        this.roomInfo = roomInfo;
        needApply.postValue(roomInfo.needApply());
        roomName.postValue(roomInfo.roomName);
        setBackground(roomInfo.getBackgroundKey());
        audienceCount.postValue(roomInfo.audienceCount);
    }

    public final MutableLiveData<Integer> audienceCount = new MutableLiveData<>();

    public final MutableLiveData<String> roomName = new MutableLiveData<>();

    public final MutableLiveData<Integer> background = new MutableLiveData<>();

    public final MutableLiveData<UserInfo> hostInfo = new MutableLiveData<>();

    public final MutableLiveData<Boolean> selfMicOn = new MutableLiveData<>(true);

    private void setBackground(@Nullable String backgroundKey) {
        if (backgroundKey == null) {
            return;
        }

        if (backgroundKey.startsWith("KTV_background_1")) {
            background.postValue(R.mipmap.ktv_background_1);
        } else if (backgroundKey.startsWith("KTV_background_2")) {
            background.postValue(R.mipmap.ktv_background_2);
        } else {
            background.postValue(R.mipmap.ktv_background_0);
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

    public boolean isInteract() {
        return myInfo.isInteract();
    }

    public final MutableLiveData<UserRoleState> userRoleState = new MutableLiveData<>(UserRoleState.NORMAL);

    public UserRoleState getUserRoleState() {
        return userRoleState.getValue();
    }

    public void updateUserRoleState(@UserRole int userRole, @UserStatus int userStatus) {
        if (userRole == UserRole.HOST) {
            userRoleState.postValue(UserRoleState.HOST);
        } else {
            if (userStatus == UserStatus.INTERACT) {
                userRoleState.postValue(UserRoleState.INTERACT);
            } else {
                userRoleState.postValue(UserRoleState.NORMAL);
            }
        }
    }

    public void requestJoinLiveRoom(String roomId) {
        KTVService.get()
                .joinRoom(roomId, new Callback<JoinRoomResponse>() {
                    @Override
                    public void onResponse(JoinRoomResponse data) {
                        if (data == null) {
                            onFailure(HttpException.unknown("Invalid JoinRoom response"));
                            return;
                        }

                        setRoomInfo(Objects.requireNonNull(data.roomInfo));

                        setHostInfo(Objects.requireNonNull(data.hostInfo));
                        setMyInfo(Objects.requireNonNull(data.userInfo));

                        requestAllSongs(roomInfo.roomId);

                        singing.postValue(
                                data.current == null ? Singing.IDLE : Singing.singing(data.current)
                        );

                        SolutionEventBus.post(new InitSeatDataEvent(data.seatMap));

                        joinRTCRoom(data.rtcToken);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        SolutionEventBus.post(new JoinRTSRoomErrorEvent(e.getCode(), e.getMessage()));
                    }
                });
    }

    public void reconnectRoom() {
        String roomId = requireRoomId();
        KTVService.get()
                .reconnect(roomId, new Callback<JoinRoomResponse>() {
                    @Override
                    public void onResponse(JoinRoomResponse data) {
                        if (data == null) {
                            onFailure(HttpException.unknown("Invalid JoinRoom response"));
                            return;
                        }
                        setRoomInfo(Objects.requireNonNull(data.roomInfo));

                        setHostInfo(Objects.requireNonNull(data.hostInfo));
                        setMyInfo(Objects.requireNonNull(data.userInfo));

                        requestAllSongs(data.roomInfo.roomId);

                        singing.postValue(
                                data.current == null ? Singing.IDLE : Singing.singing(data.current)
                        );

                        SolutionEventBus.post(new InitSeatDataEvent(data.seatMap));

                        // Reconnect no need join RTC room
                        // audienceJoinLiveRoom(data.rtcToken);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        SolutionEventBus.post(new JoinRTSRoomErrorEvent(e.getCode(), e.getMessage(), true));
                    }
                });
    }

    void joinRTCRoom(String rtcToken) {
        if (TextUtils.isEmpty(rtcToken)) {
            Log.d(TAG, "No token provided, skip join Room");
        } else {
            KTVRTCManager.ins().joinRoom(roomInfo.roomId, myUserId(), rtcToken);
        }

        if (myInfo.userStatus == UserStatus.INTERACT) {
            userRoleState.postValue(UserRoleState.INTERACT);
            startInteract();
        } else {
            userRoleState.postValue(UserRoleState.NORMAL);
            stopInteract();
        }

        selfMicOn.postValue(myInfo.isMicOn());

        requestAllSongs(roomInfo.roomId);
    }

    public void hostJoinLiveRoom(String rtcToken) {
        userRoleState.postValue(UserRoleState.HOST);

        if (TextUtils.isEmpty(rtcToken)) {
            Log.d(TAG, "No token provided, skip join Room");
        } else {
            KTVRTCManager.ins().joinRoom(roomInfo.roomId, myUserId(), rtcToken);
        }

        requestAllSongs(roomInfo.roomId);

        startInteract();
        selfMicOn.postValue(myInfo.isMicOn());
    }

    public void startInteract() {
        KTVRTCManager.ins().setUserVisibility(true);
        KTVRTCManager.ins().startAudioCapture(true);
        KTVRTCManager.ins().startAudioPublish(myInfo.isMicOn());
    }

    public void stopInteract() {
        KTVRTCManager.ins().setUserVisibility(false);
        KTVRTCManager.ins().startAudioCapture(false);
        KTVRTCManager.ins().startAudioPublish(myInfo.isMicOn());
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

    public int getPickedCount() {
        List<?> value = pickedSongs.getValue();
        return value == null ? 0 : value.size();
    }

    public void requestAllSongs(String roomId) {
        KTVService.get()
                .getPresetSongList(roomId, OnResponse.of(response -> {
                    List<SongItem> items = GetPresetSongListResponse.songs(response);
                    List<StatusSongItem> songs = Streams.map(items, item -> {
                        mSongItemMap.put(item.songId, item);
                        return new StatusSongItem(item);
                    });

                    songLibrary.postValue(songs);

                    SolutionEventBus.post(new MusicLibraryInitEvent());
                }));
    }

    public void requestPickedSongList(String roomId) {
        KTVService.get().getPickedSongList(roomId, OnResponse.of(response -> {
            List<PickedSongInfo> list = GetPickedSongListResponse.songs(response);
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
        }));
    }

    public void onRequestSongBroadcast(RequestSongBroadcast event) {
        if (isHost() || isInteract()) {
            requestPickedSongList(requireRoomId());
        }
    }

    public void onStartSingBroadcast(StartSingBroadcast event) {
        if (isHost() || isInteract()) {
            requestPickedSongList(requireRoomId());
        }
    }

    public void onFinishSingBroadcast(FinishSingBroadcast event) {
        resetControl();
        if (event.nextSong != null) {
            singing.postValue(Singing.wait(event.nextSong));
        } else {
            singing.postValue(Singing.EMPTY);
        }
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
        PickedSongInfo next = mPendingReadyToSing;
        if (next != null && songId.equals(next.songId)) {
            mPendingReadyToSing = null;
            startSingSong(next);
        } else {
            requestSong(songId);
        }
    }

    public void requestSong(String songId) {
        SongItem item = mSongItemMap.get(songId);
        if (item == null) {
            Log.d(TAG, "requestSong: SongItem not found");
            return;
        }

        String roomId = requireRoomId();
        KTVService.get().requestSong(roomId,
                myUserId(),
                item.songId,
                item.songName,
                item.duration,
                item.coverUrl, new Callback<Void>() {
                    @Override
                    public void onResponse(Void response) {
                        Log.e(TAG, "requestSong: You picked a song: " + item.songName);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        Log.e(TAG, "requestSong: error=" + e);
                        CenteredToast.show(ErrorCodes.prettyMessage(e));
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
    private PickedSongInfo mPendingReadyToSing = null;

    @Nullable
    public PickedSongInfo getCurrentSong() {
        Singing value = singing.getValue();
        assert value != null;
        return (value.state == SingState.SINGING) ? value.song : null;
    }

    public void startSingSong(PickedSongInfo next) {
        File file = MusicDownloadManager.mp3File(next.songId);
        if (file.exists()) {
            mPendingReadyToSing = null;
            if (TextUtils.equals(myUserId(), next.ownerUid)) {
                singing.postValue(Singing.singing(next));
                KTVRTCManager.ins().startAudioMixing(
                        next.songId,
                        file.getAbsolutePath(),
                        getMusicVolume(),
                        getVocalVolume()
                );
                CenteredToast.show(R.string.toast_start_singing);
            }
        } else {
            mPendingReadyToSing = next;
        }
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

    public void nextTrack() {
        PickedSongInfo curSingSong = getCurrentSong();
        if (curSingSong == null) return;
        boolean pickedBySelf = TextUtils.equals(curSingSong.ownerUid, myUserId());
        boolean isHost = isHost();
        if (!pickedBySelf && !isHost) {
            Log.d(TAG, "nextTrack: isHost=false; isOwner=false");
            return;
        }

        KTVService.get().cutOffSong(requireRoomId(), new Callback<Void>() {
            @Override
            public void onResponse(Void response) {
                // Success, Wait 'ktvOnStartSing' notify event
            }

            @Override
            public void onFailure(HttpException e) {
                CenteredToast.show(R.string.toast_cut_off_failed);
            }
        });
    }

    public void finishSinging() {
        setAudioEffect(VoiceReverbType.VOICE_REVERB_ORIGINAL);

        resetControl();

        PickedSongInfo currentSong = getCurrentSong();
        if (currentSong == null) {
            return;
        }

        String songId = currentSong.songId;

        KTVService.get()
                .finishSing(requireRoomId(), songId, 100);
    }
    // endregion

    // region Audience & Seats
    /**
     * Seat need audience to apply before taken,
     */
    public final MutableLiveData<Boolean> needApply = new MutableLiveData<>();

    public final MutableLiveData<List<UserInfo>> onlineAudiences = new MutableLiveData<>();

    public final MutableLiveData<List<UserInfo>> appliedAudiences = new MutableLiveData<>();

    private boolean selfApply = false;

    public void setSelfApply(boolean value) {
        selfApply = value;
    }

    public boolean getSelfApply() {
        return selfApply;
    }

    public void requestOnlineAudiences(String roomId) {
        KTVService.get()
                .getAudienceList(roomId, new Callback<GetAudienceResponse>() {
                    @Override
                    public void onResponse(GetAudienceResponse response) {
                        onlineAudiences.postValue(GetAudienceResponse.audiences(response));
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        onlineAudiences.postValue(Collections.emptyList());
                    }
                });
    }

    public void requestApplyAudiences(String roomId) {
        KTVService.get()
                .getApplyAudienceList(roomId, new Callback<GetAudienceResponse>() {
                    @Override
                    public void onResponse(GetAudienceResponse response) {
                        appliedAudiences.postValue(GetAudienceResponse.audiences(response));
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        appliedAudiences.postValue(Collections.emptyList());
                    }
                });
    }

    public void updateNeedApply(String roomId, boolean newValue) {
        int type = newValue ? NeedApplyOption.NEED : NeedApplyOption.NO_NEED;

        KTVService.get()
                .manageInteractApply(roomId, type, new Callback<Void>() {
                    @Override
                    public void onResponse(Void response) {
                        needApply.postValue(newValue);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        needApply.postValue(!newValue);
                    }
                });
    }

    public void replyApply(String roomId, String userId, boolean agree) {
        if (!agree) {
            // TODO Host replayed rejected
            Log.d(TAG, "Host replayed rejected");
            return;
        }
        KTVService.get().agreeApply(roomId, userId, new Callback<Void>() {
            @Override
            public void onResponse(Void response) {
                Log.d(TAG, "Host replyApply: success");
            }

            @Override
            public void onFailure(HttpException e) {
                CenteredToast.show(ErrorCodes.prettyMessage(e));
            }
        });
    }

    public void inviteInteract(String roomId, String userId, int seatId) {
        KTVService.get()
                .inviteInteract(roomId, userId, seatId, new Callback<Void>() {
                    @Override
                    public void onResponse(Void response) {
                        CenteredToast.show(R.string.toast_invitation_audience);
                        requestOnlineAudiences(roomId);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(ErrorCodes.prettyMessage(e));
                    }
                });
    }

    public void replyInvite(String roomId, int seatId, @ReplyType int reply) {
        KTVService.get()
                .replyInvite(roomId, seatId, reply, new Callback<Void>() {
                    @Override
                    public void onResponse(Void response) {
                        Log.d(TAG, "replyInvite: success; seatId=" + seatId + "; reply=" + reply);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(ErrorCodes.prettyMessage(e));
                    }
                });
    }

    public void updateSelfMediaStatus(String roomId, boolean isMicOn) {
        myInfo.mic = isMicOn ? MediaStatus.ON : MediaStatus.OFF;
        selfMicOn.postValue(isMicOn);

        KTVService.get().updateSelfMicStatus(roomId, isMicOn);
        KTVRTCManager.ins().startAudioPublish(isMicOn);
    }

    public void applySeatRequest(@NonNull String roomId, int seatId) {
        setSelfApply(true);
        KTVService.get()
                .applyInteract(roomId, seatId,
                        new Callback<ApplyInteractResponse>() {
                            @Override
                            public void onResponse(ApplyInteractResponse response) {
                                if (response == null) {
                                    onFailure(HttpException.unknown("Response is null"));
                                    return;
                                }
                                if (response.needApply) {
                                    CenteredToast.show(R.string.toast_apply_guest);
                                }
                            }

                            @Override
                            public void onFailure(HttpException e) {
                                Log.d(TAG, "onError: e=" + e);
                                setSelfApply(false);
                                CenteredToast.show(ErrorCodes.prettyMessage(e));
                            }
                        });
    }

    public void managerSeat(String roomId, int seatId, @SeatOption int option) {
        KTVService.get()
                .manageSeat(roomId, seatId, option);
    }

    public void finishInteract(String roomId, int seatId) {
        KTVService.get()
                .finishInteract(roomId, seatId);
    }
    // endregion

    // region Tuning & Control
    public final MutableLiveData<Boolean> originTrack = new MutableLiveData<>(false);

    public final MutableLiveData<Boolean> isAudioMixing = new MutableLiveData<>(false);

    public final MutableLiveData<Boolean> earMonitorSwitch = new MutableLiveData<>(false);

    @NonNull
    private VoiceReverbType voiceReverbType = Defaults.VOICE_REVERB_TYPE;
    @IntRange(from = 0, to = 100)
    private int musicVolume = Defaults.MUSIC_VOLUME;
    @IntRange(from = 0, to = 100)
    private int vocalVolume = Defaults.VOCAL_VOLUME;
    @IntRange(from = 0, to = 100)
    private int earMonitorVolume = Defaults.EAR_MONITOR_VOLUME;

    @NonNull
    public VoiceReverbType getVoiceReverbType() {
        return voiceReverbType;
    }

    public int getMusicVolume() {
        return musicVolume;
    }

    public int getVocalVolume() {
        return vocalVolume;
    }

    public int getEarMonitorVolume() {
        return earMonitorVolume;
    }

    public void setEarMonitorSwitch(boolean enable) {
        earMonitorSwitch.postValue(enable);
        if (enable) {
            KTVRTCManager.ins().openEarMonitor(earMonitorVolume);
        } else {
            KTVRTCManager.ins().closeEarMonitor();
        }
    }

    public void setAudioEffect(@NonNull VoiceReverbType type) {
        if (voiceReverbType == type) {
            return;
        }
        voiceReverbType = type;
        KTVRTCManager.ins().setAudioEffect(type);
    }

    public void setVocalVolume(@IntRange(from = 0, to = 100) int progress) {
        vocalVolume = progress;
        KTVRTCManager.ins().adjustUserVolume(progress);
    }

    public void setMusicVolume(@IntRange(from = 0, to = 100) int progress) {
        musicVolume = progress;
        KTVRTCManager.ins().adjustSongVolume(progress);
    }

    public void setEarMonitorVolume(@IntRange(from = 0, to = 100) int progress) {
        earMonitorVolume = progress;
        KTVRTCManager.ins().adjustEarMonitorVolume(progress);
    }

    public void resetControl() {
        earMonitorSwitch.postValue(false);
        musicVolume = Defaults.MUSIC_VOLUME;
        vocalVolume = Defaults.VOCAL_VOLUME;
        earMonitorVolume = Defaults.EAR_MONITOR_VOLUME;
        voiceReverbType = Defaults.VOICE_REVERB_TYPE;

        KTVRTCManager manager = KTVRTCManager.ins();
        manager.resetAudioMixingDualMonoMode();
        manager.adjustSongVolume(Defaults.MUSIC_VOLUME);
        manager.adjustUserVolume(Defaults.VOCAL_VOLUME);
        manager.closeEarMonitor();

        isAudioMixing.postValue(false);
        originTrack.postValue(false);
    }

    public void switchTrack() {
        boolean playAccompany = KTVRTCManager.ins().toggleAudioAccompanyMode();
        if (playAccompany) {
            CenteredToast.show(R.string.toast_backing_track_enabled);
            originTrack.postValue(false);
        } else {
            CenteredToast.show(R.string.toast_original_vocals_enabled);
            originTrack.postValue(true);
        }
    }

    public void switchPausePlay() {
        boolean inAudioMixing = KTVRTCManager.ins().inAudioMixing;
        if (inAudioMixing) {
            KTVRTCManager.ins().pauseAudioMixing();
            isAudioMixing.postValue(false);
        } else {
            KTVRTCManager.ins().resumeAudioMixing();
            isAudioMixing.postValue(true);
        }
    }
    // endregion
}
