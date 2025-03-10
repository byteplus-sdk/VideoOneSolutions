// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.solution.ktv.http;

import com.google.gson.JsonObject;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.SolutionHttpService;
import com.vertcdemo.core.http.callback.OnNext;
import com.vertcdemo.solution.ktv.http.response.ApplyInteractResponse;
import com.vertcdemo.solution.ktv.core.rts.annotation.NeedApplyOption;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatOption;
import com.vertcdemo.solution.ktv.http.response.CreateRoomResponse;
import com.vertcdemo.solution.ktv.http.response.GetAudienceResponse;
import com.vertcdemo.solution.ktv.http.response.GetPickedSongListResponse;
import com.vertcdemo.solution.ktv.http.response.GetPresetSongListResponse;
import com.vertcdemo.solution.ktv.http.response.GetRoomListResponse;
import com.vertcdemo.solution.ktv.http.response.JoinRoomResponse;

public class KTVService extends SolutionHttpService {

    private static final KTVService INSTANCE = new KTVService();

    public static KTVService get() {
        return INSTANCE;
    }

    private static final String CMD_CLEAR_USER = "ktvClearUser";
    private static final String CMD_GET_ROOM_LIST = "ktvGetActiveLiveRoomList";

    private static final String CMD_START_LIVE = "ktvStartLive";
    private static final String CMD_FINISH_LIVE = "ktvFinishLive";

    private static final String CMD_JOIN_ROOM = "ktvJoinLiveRoom";
    private static final String CMD_LEAVE_ROOM = "ktvLeaveLiveRoom";

    private static final String CMD_RECONNECT = "ktvReconnect";

    private static final String CMD_SEND_MESSAGE = "ktvSendMessage";

    private static final String CMD_PRESET_SONGS = "ktvGetPresetSongList";
    private static final String CMD_PICKED_SONGS = "ktvGetRequestSongList";
    private static final String CMD_REQUEST_SONG = "ktvRequestSong";

    private static final String CMD_CUT_OFF_SONG = "ktvCutOffSong";
    private static final String CMD_FINISH_SING = "ktvFinishSing";

    private static final String CMD_GET_AUDIENCE_LIST = "ktvGetAudienceList";
    private static final String CMD_GET_APPLY_AUDIENCE_LIST = "ktvGetApplyAudienceList";
    private static final String CMD_INVITE_INTERACT = "ktvInviteInteract";
    private static final String CMD_AGREE_APPLY = "ktvAgreeApply";
    private static final String CMD_MANAGE_INTERACT_APPLY = "ktvManageInteractApply";
    private static final String CMD_MANAGE_SEAT = "ktvManageSeat";

    private static final String CMD_APPLY_INTERACT = "ktvApplyInteract";
    private static final String CMD_REPLY_INVITE = "ktvReplyInvite";
    private static final String CMD_FINISH_INTERACT = "ktvFinishInteract";

    private static final String CMD_UPDATE_MEDIA_STATUS = "ktvUpdateMediaStatus";

    private KTVService() {
    }

    public void clearUser(Runnable next) {
        JsonObject params = getCommonParams();
        request(CMD_CLEAR_USER, params, OnNext.of(next));
    }

    public void getRoomList(Callback<GetRoomListResponse> callback) {
        JsonObject params = getCommonParams();
        request(CMD_GET_ROOM_LIST, params, GetRoomListResponse.class, callback);
    }

    public void startLive(String roomName, String backgroundImageName, Callback<CreateRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        params.addProperty("room_name", roomName);
        params.addProperty("background_image_name", backgroundImageName);
        request(CMD_START_LIVE, params, CreateRoomResponse.class, callback);
    }

    public void finishLive(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_FINISH_LIVE, params, OnNext.empty());
    }

    public void joinRoom(String roomId, Callback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());

        request(CMD_JOIN_ROOM, params, JoinRoomResponse.class, callback);
    }

    public void leaveRoom(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_LEAVE_ROOM, params, OnNext.empty());
    }

    public void reconnect(String roomId, Callback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        request(CMD_RECONNECT, params, JoinRoomResponse.class, callback);
    }

    public void sendMessage(String roomId, String message) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("message", message);

        request(CMD_SEND_MESSAGE, params, OnNext.empty());
    }

    public void getPresetSongList(String roomId, Callback<GetPresetSongListResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_PRESET_SONGS, params, GetPresetSongListResponse.class, callback);
    }

    public void getPickedSongList(String roomId, Callback<GetPickedSongListResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_PICKED_SONGS, params, GetPickedSongListResponse.class, callback);
    }

    public void requestSong(String roomId,
                            String userId,
                            String songId,
                            String songName,
                            int songDuration,
                            String coverUrl, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        params.addProperty("song_id", songId);
        params.addProperty("song_name", songName);
        params.addProperty("song_duration", songDuration);
        params.addProperty("cover_url", coverUrl);

        request(CMD_REQUEST_SONG, params, callback);
    }

    public void cutOffSong(String roomId) {
        cutOffSong(roomId, OnNext.empty());
    }

    public void cutOffSong(String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_CUT_OFF_SONG, params, callback);
    }

    public void finishSing(String roomId, String songId, float score) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("song_id", songId);
        params.addProperty("score", score);
        request(CMD_FINISH_SING, params, OnNext.empty());
    }

    public void getAudienceList(String roomId, Callback<GetAudienceResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_GET_AUDIENCE_LIST, params, GetAudienceResponse.class, callback);
    }

    public void getApplyAudienceList(String roomId, Callback<GetAudienceResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_GET_APPLY_AUDIENCE_LIST, params, GetAudienceResponse.class, callback);
    }

    public void inviteInteract(String roomId, String audienceUserId, int seatId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("seat_id", seatId);

        request(CMD_INVITE_INTERACT, params, callback);
    }

    public void agreeApply(String roomId, String audienceUserId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("audience_room_id", roomId);

        request(CMD_AGREE_APPLY, params, callback);
    }

    public void manageInteractApply(String roomId, @NeedApplyOption int type, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("type", type);

        request(CMD_MANAGE_INTERACT_APPLY, params, callback);
    }

    public void manageSeat(String roomId, int seatId, @SeatOption int type) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);
        params.addProperty("type", type);

        request(CMD_MANAGE_SEAT, params, OnNext.empty());
    }

    public void applyInteract(String roomId, int seatId, Callback<ApplyInteractResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);

        request(CMD_APPLY_INTERACT, params, ApplyInteractResponse.class, callback);
    }


    public void replyInvite(String roomId, int seatId, @ReplyType int reply, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("reply", reply);
        params.addProperty("seat_id", seatId);

        request(CMD_REPLY_INVITE, params, callback);
    }

    public void finishInteract(String roomId, int seatId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);

        request(CMD_FINISH_INTERACT, params, OnNext.empty());
    }

    public void updateSelfMicStatus(String roomId, boolean isMicOn) {
        int micOption = isMicOn ? MediaStatus.ON : MediaStatus.OFF;

        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("mic", micOption);

        request(CMD_UPDATE_MEDIA_STATUS, params, OnNext.empty());
    }
}
