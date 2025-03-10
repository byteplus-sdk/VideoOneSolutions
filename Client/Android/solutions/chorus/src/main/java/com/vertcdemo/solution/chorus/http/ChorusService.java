// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.solution.chorus.http;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.SolutionHttpService;
import com.vertcdemo.core.http.callback.OnNext;
import com.vertcdemo.solution.chorus.http.response.GetPickedSongListResponse;
import com.vertcdemo.solution.chorus.http.response.GetPresetSongListResponse;
import com.vertcdemo.solution.chorus.http.response.JoinRoomResponse;
import com.vertcdemo.solution.chorus.core.rts.annotation.SingType;
import com.vertcdemo.solution.chorus.http.response.CreateRoomResponse;
import com.vertcdemo.solution.chorus.http.response.GetRoomListResponse;

public class ChorusService extends SolutionHttpService {
    private static final ChorusService service = new ChorusService();

    public static ChorusService get() {
        return service;
    }

    private static final String CMD_CLEAR_USER = "owcClearUser";
    private static final String CMD_GET_ROOM_LIST = "owcGetActiveLiveRoomList";

    private static final String CMD_START_LIVE = "owcStartLive";
    private static final String CMD_FINISH_LIVE = "owcFinishLive";

    private static final String CMD_JOIN_ROOM = "owcJoinLiveRoom";
    private static final String CMD_LEAVE_ROOM = "owcLeaveLiveRoom";

    private static final String CMD_RECONNECT = "owcReconnect";

    private static final String CMD_SEND_MESSAGE = "owcSendMessage";

    private static final String CMD_PRESET_SONGS = "owcGetPresetSongList";
    private static final String CMD_PICKED_SONGS = "owcGetRequestSongList";
    private static final String CMD_REQUEST_SONG = "owcRequestSong";

    private static final String CMD_START_SING = "owcStartSing";
    private static final String CMD_CUT_OFF_SONG = "owcCutOffSong";
    private static final String CMD_FINISH_SING = "owcFinishSing";

    private ChorusService(){

    }

    public void clearUser(@NonNull Runnable next) {
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

    public void startSing(String roomId,
                          String songId,
                          @SingType String type) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("song_id", songId);
        params.addProperty("type", type);
        request(CMD_START_SING, params, OnNext.empty());
    }

    public void cutOffSong(String roomId, String userId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        request(CMD_CUT_OFF_SONG, params, callback);
    }

    public void finishSing(String roomId, String songId, float score) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("song_id", songId);
        params.addProperty("score", score);
        request(CMD_FINISH_SING, params, OnNext.empty());
    }
}
