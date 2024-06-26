// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;

import android.util.Log;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.common.RebroadcastEventListener;
import com.vertcdemo.core.event.ClearUserEvent;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.RequestCallbackAdapter;
import com.vertcdemo.core.net.rts.RTSBaseClient;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.core.net.rts.RTSRequest;
import com.vertcdemo.solution.chorus.bean.CreateRoomResponse;
import com.vertcdemo.solution.chorus.bean.FinishLiveInform;
import com.vertcdemo.solution.chorus.bean.FinishSingInform;
import com.vertcdemo.solution.chorus.bean.GetActiveRoomsResponse;
import com.vertcdemo.solution.chorus.bean.GetPresetSongListResponse;
import com.vertcdemo.solution.chorus.bean.GetRequestSongResponse;
import com.vertcdemo.solution.chorus.bean.JoinRoomResponse;
import com.vertcdemo.solution.chorus.bean.MessageInform;
import com.vertcdemo.solution.chorus.bean.PickedSongInform;
import com.vertcdemo.solution.chorus.bean.StartSingInform;
import com.vertcdemo.solution.chorus.bean.WaitSingInform;
import com.vertcdemo.solution.chorus.core.rts.annotation.SingType;
import com.vertcdemo.solution.chorus.event.AudienceChangedEvent;

public class ChorusRTSClient extends RTSBaseClient {
    private static final String TAG = "RTSClient";

    private static final String GET_LIVE_ROOM_LIST = "owcGetActiveLiveRoomList";
    private static final String START_LIVE = "owcStartLive";
    private static final String FINISH_LIVE = "owcFinishLive";
    private static final String JOIN_LIVE_ROOM = "owcJoinLiveRoom";
    private static final String LEAVE_LIVE_ROOM = "owcLeaveLiveRoom";
    private static final String CLEAR_USER = "owcClearUser";
    private static final String REQUEST_SONG_LIST = "owcGetRequestSongList";
    private static final String SEND_MESSAGE = "owcSendMessage";
    private static final String START_SING = "owcStartSing";
    private static final String SKIP_SONG = "owcCutOffSong";
    private static final String FINISH_SING = "owcFinishSing";
    private static final String RECONNECT = "owcReconnect";

    public ChorusRTSClient(RTCVideo rtcVideo, RTSInfo rtsInfo) {
        super(rtcVideo, rtsInfo);
        initEventListener();
    }

    /**
     * 获取合唱房列表
     */
    public void getActiveRoomList(IRequestCallback<GetActiveRoomsResponse> callback) {
        JsonObject params = getCommonParams();
        sendServerMessageOnNetwork(GET_LIVE_ROOM_LIST, "", params, GetActiveRoomsResponse.class, callback);
    }

    /**
     * 创建合唱房
     */
    public void requestStartLive(String roomName, String backgroundImageName, IRequestCallback<CreateRoomResponse> callback) {
        AppExecutors.networkIO().execute(() -> {
            JsonObject params = getCommonParams();
            params.addProperty("user_name", SolutionDataManager.ins().getUserName());
            params.addProperty("room_name", roomName);
            params.addProperty("background_image_name", backgroundImageName);
            sendServerMessageOnNetwork(START_LIVE, "", params, CreateRoomResponse.class, callback);
        });
    }

    /**
     * 解散合唱房
     */
    public void requestFinishLive(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(FINISH_LIVE, roomId, params, null, null);
    }

    /**
     * 离开合唱房
     */
    public void requestLeaveRoom(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(LEAVE_LIVE_ROOM, roomId, params, null, null);
    }

    /**
     * 加入合唱房
     */
    public void requestJoinRoom(String roomId, IRequestCallback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        sendServerMessageOnNetwork(JOIN_LIVE_ROOM, roomId, params, JoinRoomResponse.class, callback);
    }

    public void requestClearUser(Runnable next) {
        JsonObject params = getCommonParams();
        sendServerMessageOnNetwork(CLEAR_USER, "", params, null, RequestCallbackAdapter.create(next));
    }

    public void startSing(String roomId,
                          String songId,
                          @SingType String type) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("song_id", songId);
        params.addProperty("type", type);
        sendServerMessageOnNetwork(START_SING, roomId, params, null, new IRequestCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                Log.w(TAG, "[Chorus] startSing: onSuccess");
            }

            @Override
            public void onError(int errorCode, String message) {
                Log.w(TAG, "[Chorus] startSing: onError: " + errorCode + ", " + message);
            }
        });
    }

    /**
     * 切歌
     */
    public void cutOffSong(String roomId, String userId, IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        sendServerMessageOnNetwork(SKIP_SONG, roomId, params, Void.class, callback);
    }

    /**
     * 演唱结束
     */
    public void finishSing(String roomId, String songId, float score) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("song_id", songId);
        params.addProperty("score", score);
        sendServerMessageOnNetwork(FINISH_SING, roomId, params, Void.class, new IRequestCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                Log.d(TAG, "finishSing: onSuccess: ");
            }
        });
    }

    /**
     * 向业务服务器请求已点列表
     *
     * @param roomId roomId
     */
    public void getRequestSongList(String roomId, IRequestCallback<GetRequestSongResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(REQUEST_SONG_LIST, roomId, params, GetRequestSongResponse.class, callback);
    }

    /**
     * 查询该用户当前状态(正在开播、正在互动等)及恢复状态所需信息，用于互踢、断线重连、crash重连。
     */
    public void reconnectToServer(String roomId, IRequestCallback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        sendServerMessageOnNetwork(RECONNECT, roomId, params, JoinRoomResponse.class, callback);
    }

    public void sendMessage(String roomId, String message) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("message", message);
        sendServerMessageOnNetwork(SEND_MESSAGE, roomId, params, null, null);
    }

    private static final String ON_FINISH_LIVE = "owcOnFinishLive";
    private static final String ON_AUDIENCE_JOIN_ROOM = "owcOnAudienceJoinRoom";
    private static final String ON_AUDIENCE_LEAVE_ROOM = "owcOnAudienceLeaveRoom";
    private static final String ON_MESSAGE = "owcOnMessage";
    private static final String ON_MEDIA_OPERATE = "owcOnMediaOperate";
    private static final String ON_CLEAR_USER = "owcOnClearUser";
    private static final String ON_PICK_SONG = "owcOnRequestSong";
    private static final String ON_WAIT_SING = "owcOnWaitSing";
    private static final String ON_START_SING = "owcOnStartSing";
    private static final String ON_FINISH_SING = "owcOnFinishSing";

    private void initEventListener() {
        //聊天区消息
        registerEventListener(ON_MESSAGE, RebroadcastEventListener.of(MessageInform.class));
        //互踢: 用户在其它端登陆时，会给前一个登陆端下发该通知，收到后不用调用退房接口，直接关闭即可
        registerEventListener(ON_CLEAR_USER, RebroadcastEventListener.of(ClearUserEvent.class));
        //观众进房通知
        registerEventListener(ON_AUDIENCE_JOIN_ROOM, RebroadcastEventListener.of(AudienceChangedEvent.Join.class));
        //观众离房通知
        registerEventListener(ON_AUDIENCE_LEAVE_ROOM, RebroadcastEventListener.of(AudienceChangedEvent.Leave.class));
        //结束直播通知
        registerEventListener(ON_FINISH_LIVE, RebroadcastEventListener.of(FinishLiveInform.class));
        //开始演唱
        registerEventListener(ON_START_SING, RebroadcastEventListener.of(StartSingInform.class));
        //等待演唱
        registerEventListener(ON_WAIT_SING, RebroadcastEventListener.of(WaitSingInform.class));
        //演唱结束通知
        registerEventListener(ON_FINISH_SING, RebroadcastEventListener.of(FinishSingInform.class));
        //点歌通知
        registerEventListener(ON_PICK_SONG, RebroadcastEventListener.of(PickedSongInform.class));
    }

    private <T> void sendServerMessageOnNetwork(String eventName,
                                                String roomId,
                                                JsonObject content,
                                                Class<T> resultClass,
                                                IRequestCallback<T> callback) {
        sendServerMessage(eventName, roomId, content, new RTSRequest<>(callback, resultClass));
    }

    private static final String CMD_REQUEST_PICKED_SONGS = "owcGetRequestSongList";
    private static final String CMD_REQUEST_PRESET_SONGS = "owcGetPresetSongList";
    private static final String CMD_REQUEST_SONG = "owcRequestSong";

    /**
     * 向业务服务器请求已点列表
     *
     * @param roomId requireRoomId
     */
    public void requestPickedSongList(String roomId, IRequestCallback<GetRequestSongResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_REQUEST_PICKED_SONGS, roomId, params, GetRequestSongResponse.class, callback);
    }

    private JsonObject getCommonParams() {
        JsonObject params = new JsonObject();
        params.addProperty("app_id", mRTSInfo.appId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        params.addProperty("device_id", SolutionDataManager.ins().getDeviceId());
        return params;
    }

    public void requestPresetSongList(String roomId, IRequestCallback<GetPresetSongListResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("login_token", SolutionDataManager.ins().getToken());
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_REQUEST_PRESET_SONGS, roomId, params, GetPresetSongListResponse.class, callback);
    }

    public void requestSong(String roomId,
                            String userId,
                            String songId,
                            String songName,
                            float songDuration,
                            String coverUrl,
                            IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("login_token", SolutionDataManager.ins().getToken());
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        params.addProperty("song_id", songId);
        params.addProperty("song_name", songName);
        params.addProperty("song_duration", songDuration);
        params.addProperty("cover_url", coverUrl);
        sendServerMessageOnNetwork(CMD_REQUEST_SONG, roomId, params, Void.class, callback);
    }
}
