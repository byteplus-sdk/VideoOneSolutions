// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core;

import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.common.RebroadcastEventListener;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.RequestCallbackAdapter;
import com.vertcdemo.core.net.rts.RTSBaseClient;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.core.net.rts.RTSRequest;
import com.vertcdemo.solution.ktv.bean.CreateRoomResponse;
import com.vertcdemo.solution.ktv.bean.GetActiveKTVListResponse;
import com.vertcdemo.solution.ktv.bean.GetAudienceResponse;
import com.vertcdemo.solution.ktv.bean.GetPresetSongListResponse;
import com.vertcdemo.solution.ktv.bean.GetRequestSongResponse;
import com.vertcdemo.solution.ktv.bean.JoinRoomResponse;
import com.vertcdemo.solution.ktv.bean.ReplyMicOnResponse;
import com.vertcdemo.solution.ktv.bean.ReplyResponse;
import com.vertcdemo.solution.ktv.core.rts.annotation.NeedApplyOption;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatOption;
import com.vertcdemo.solution.ktv.event.AudienceApplyBroadcast;
import com.vertcdemo.solution.ktv.event.AudienceChangedBroadcast;
import com.vertcdemo.solution.ktv.event.ClearUserBroadcast;
import com.vertcdemo.solution.ktv.event.FinishLiveBroadcast;
import com.vertcdemo.solution.ktv.event.FinishSingBroadcast;
import com.vertcdemo.solution.ktv.event.InteractChangedBroadcast;
import com.vertcdemo.solution.ktv.event.InteractResultBroadcast;
import com.vertcdemo.solution.ktv.event.MediaChangedBroadcast;
import com.vertcdemo.solution.ktv.event.MediaOperateBroadcast;
import com.vertcdemo.solution.ktv.event.MessageBroadcast;
import com.vertcdemo.solution.ktv.event.ReceivedInteractBroadcast;
import com.vertcdemo.solution.ktv.event.RequestSongBroadcast;
import com.vertcdemo.solution.ktv.event.SeatChangedBroadcast;
import com.vertcdemo.solution.ktv.event.StartSingBroadcast;

public class KTVRTSClient extends RTSBaseClient {
    private static final String CMD_START_LIVE = "ktvStartLive";
    private static final String CMD_GET_AUDIENCE_LIST = "ktvGetAudienceList";
    private static final String CMD_GET_APPLY_AUDIENCE_LIST = "ktvGetApplyAudienceList";
    private static final String CMD_INVITE_INTERACT = "ktvInviteInteract";
    private static final String CMD_AGREE_APPLY = "ktvAgreeApply";
    private static final String CMD_MANAGE_INTERACT_APPLY = "ktvManageInteractApply";
    private static final String CMD_MANAGE_SEAT = "ktvManageSeat";
    private static final String CMD_FINISH_LIVE = "ktvFinishLive";
    private static final String CMD_JOIN_LIVE_ROOM = "ktvJoinLiveRoom";
    private static final String CMD_REPLY_INVITE = "ktvReplyInvite";
    private static final String CMD_FINISH_INTERACT = "ktvFinishInteract";
    private static final String CMD_APPLY_INTERACT = "ktvApplyInteract";
    private static final String CMD_LEAVE_LIVE_ROOM = "ktvLeaveLiveRoom";
    private static final String CMD_GET_ACTIVE_LIVE_ROOM_LIST = "ktvGetActiveLiveRoomList";
    private static final String CMD_RECONNECT = "ktvReconnect";
    private static final String CMD_CLEAR_USER = "ktvClearUser";
    private static final String CMD_UPDATE_MEDIA_STATUS = "ktvUpdateMediaStatus";
    private static final String CMD_REQUEST_SONG = "ktvRequestSong";
    private static final String CMD_CUTOFF_SONG = "ktvCutOffSong";
    private static final String CMD_FINISH_SING = "ktvFinishSing";
    private static final String CMD_REQUEST_PICKED_SONGS = "ktvGetRequestSongList";

    private static final String CMD_REQUEST_PRESET_SONGS = "ktvGetPresetSongList";

    private static final String CMD_SEND_MESSAGE = "ktvSendMessage";

    public KTVRTSClient(RTCVideo engine, RTSInfo rtsInfo) {
        super(engine, rtsInfo);
        initEventListener();
    }

    private JsonObject getCommonParams() {
        JsonObject params = new JsonObject();
        params.addProperty("app_id", mRTSInfo.appId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        params.addProperty("device_id", SolutionDataManager.ins().getDeviceId());
        return params;
    }

    public void requestStartLive(String roomName, String backgroundImageName, IRequestCallback<CreateRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        params.addProperty("room_name", roomName);
        params.addProperty("background_image_name", backgroundImageName);
        sendServerMessageOnNetwork(CMD_START_LIVE, "", params, CreateRoomResponse.class, callback);
    }

    public void requestAudienceList(String roomId, IRequestCallback<GetAudienceResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_GET_AUDIENCE_LIST, roomId, params, GetAudienceResponse.class, callback);
    }

    public void requestApplyAudienceList(String roomId, IRequestCallback<GetAudienceResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_GET_APPLY_AUDIENCE_LIST, roomId, params, GetAudienceResponse.class, callback);
    }

    public void inviteInteract(String roomId, String audienceUserId, int seatId, IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("seat_id", seatId);
        sendServerMessageOnNetwork(CMD_INVITE_INTERACT, roomId, params, null, callback);
    }

    public void agreeApply(String roomId, String audienceUserId, String audienceRoomId, IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        sendServerMessageOnNetwork(CMD_AGREE_APPLY, roomId, params, null, callback);
    }

    public void manageInteractApply(String roomId, @NeedApplyOption int type, IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("type", type);
        sendServerMessageOnNetwork(CMD_MANAGE_INTERACT_APPLY, roomId, params, null, callback);
    }

    public void managerSeat(String roomId, int seatId, @SeatOption int type, IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);
        params.addProperty("type", type);
        sendServerMessageOnNetwork(CMD_MANAGE_SEAT, roomId, params, null, callback);
    }

    public void requestFinishLive(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_FINISH_LIVE, roomId, params, null, null);
    }

    public void requestLeaveRoom(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LEAVE_LIVE_ROOM, roomId, params, null, null);
    }

    public void requestJoinRoom(String roomId, IRequestCallback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        sendServerMessageOnNetwork(CMD_JOIN_LIVE_ROOM, roomId, params, JoinRoomResponse.class, callback);
    }

    public void replyInvite(String roomId, @ReplyType int reply, int seatId, IRequestCallback<ReplyResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("reply", reply);
        params.addProperty("seat_id", seatId);
        sendServerMessageOnNetwork(CMD_REPLY_INVITE, roomId, params, ReplyResponse.class, callback);
    }

    public void finishInteract(String roomId, int seatId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);
        sendServerMessageOnNetwork(CMD_FINISH_INTERACT, roomId, params, null, null);
    }


    public void applyInteract(String roomId, int seatId, IRequestCallback<ReplyMicOnResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("seat_id", seatId);
        sendServerMessageOnNetwork(CMD_APPLY_INTERACT, roomId, params, ReplyMicOnResponse.class, callback);
    }

    public void getActiveRoomList(IRequestCallback<GetActiveKTVListResponse> callback) {
        JsonObject params = getCommonParams();
        sendServerMessageOnNetwork(CMD_GET_ACTIVE_LIVE_ROOM_LIST, "", params, GetActiveKTVListResponse.class, callback);
    }


    public void requestClearUser(Runnable next) {
        JsonObject params = getCommonParams();
        sendServerMessageOnNetwork(CMD_CLEAR_USER, "", params, null, RequestCallbackAdapter.create(next));
    }

    public void updateSelfMediaStatus(String roomId, @MediaStatus int micOption) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        params.addProperty("mic", micOption);
        sendServerMessageOnNetwork(CMD_UPDATE_MEDIA_STATUS, roomId, params, null, null);
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

    public void cutOffSong(String roomId, String userId) {
        cutOffSong(roomId, userId, null);
    }

    public void cutOffSong(String roomId, String userId, @Nullable IRequestCallback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("login_token", SolutionDataManager.ins().getToken());
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        sendServerMessageOnNetwork(CMD_CUTOFF_SONG, roomId, params, null, callback);
    }

    public void finishSing(String roomId, String userId, String songId, float score) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_id", userId);
        params.addProperty("song_id", songId);
        params.addProperty("score", score);
        sendServerMessageOnNetwork(CMD_FINISH_SING, roomId, params, null, null);
    }

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

    public void requestPresetSongList(String roomId, IRequestCallback<GetPresetSongListResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("login_token", SolutionDataManager.ins().getToken());
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_REQUEST_PRESET_SONGS, roomId, params, GetPresetSongListResponse.class, callback);
    }

    public void reconnectToServer(String roomId, IRequestCallback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_RECONNECT, roomId, params, JoinRoomResponse.class, callback);
    }

    public void sendMessage(String roomId, String message) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("message", message);
        sendServerMessageOnNetwork(CMD_SEND_MESSAGE, roomId, params, null, null);
    }

    private static final String ON_AUDIENCE_JOIN_ROOM = "ktvOnAudienceJoinRoom";
    private static final String ON_AUDIENCE_LEAVE_ROOM = "ktvOnAudienceLeaveRoom";
    private static final String ON_FINISH_LIVE = "ktvOnFinishLive";
    private static final String ON_JOIN_INTERACT = "ktvOnJoinInteract";
    private static final String ON_FINISH_INTERACT = "ktvOnFinishInteract";
    private static final String ON_SEAT_CHANGE = "ktvOnSeatStatusChange";
    private static final String ON_MEDIA_STATUS_CHANGE = "ktvOnMediaStatusChange";
    private static final String ON_MESSAGE = "ktvOnMessage";
    private static final String ON_INVITE_INTERACT = "ktvOnInviteInteract";
    private static final String ON_APPLY_INTERACT = "ktvOnApplyInteract";
    private static final String ON_INVITE_RESULT = "ktvOnInviteResult";
    private static final String ON_MEDIA_OPERATE = "ktvOnMediaOperate";
    private static final String ON_CLEAR_USER = "ktvOnClearUser";
    private static final String ON_REQUEST_SONG = "ktvOnRequestSong";
    private static final String ON_FINISH_SONG = "ktvOnFinishSing";
    private static final String ON_START_SONG = "ktvOnStartSing";

    private void initEventListener() {
        //观众进房通知
        registerEventListener(ON_AUDIENCE_JOIN_ROOM,
                RebroadcastEventListener.of(AudienceChangedBroadcast.Join.class));
        //观众离房通知
        registerEventListener(ON_AUDIENCE_LEAVE_ROOM,
                RebroadcastEventListener.of(AudienceChangedBroadcast.Leave.class));
        //结束直播通知
        registerEventListener(ON_FINISH_LIVE,
                RebroadcastEventListener.of(FinishLiveBroadcast.class));
        //加入互动通知
        registerEventListener(ON_JOIN_INTERACT, RebroadcastEventListener.of(InteractChangedBroadcast.Join.class));
        //结束互动通知
        registerEventListener(ON_FINISH_INTERACT, RebroadcastEventListener.of(InteractChangedBroadcast.Finish.class));

        registerEventListener(ON_SEAT_CHANGE, RebroadcastEventListener.of(SeatChangedBroadcast.class));
        //麦克风状态变化
        registerEventListener(ON_MEDIA_STATUS_CHANGE, RebroadcastEventListener.of(MediaChangedBroadcast.class));
        //聊天区消息
        registerEventListener(ON_MESSAGE, RebroadcastEventListener.of(MessageBroadcast.class));
        //互动邀请
        registerEventListener(ON_INVITE_INTERACT, RebroadcastEventListener.of(ReceivedInteractBroadcast.class));
        //互动申请
        registerEventListener(ON_APPLY_INTERACT, RebroadcastEventListener.of(AudienceApplyBroadcast.class));
        //邀请结果:接受/拒绝，通知主播
        registerEventListener(ON_INVITE_RESULT, RebroadcastEventListener.of(InteractResultBroadcast.class));
        //麦克风操作:主播mute/unmute嘉宾麦克风
        registerEventListener(ON_MEDIA_OPERATE, RebroadcastEventListener.of(MediaOperateBroadcast.class));
        //互踢: 用户在其它端登陆时，会给前一个登陆端下发该通知，收到后不用调用退房接口，直接关闭即可
        registerEventListener(ON_CLEAR_USER, RebroadcastEventListener.of(ClearUserBroadcast.class));
        //点歌通知
        registerEventListener(ON_REQUEST_SONG, RebroadcastEventListener.of(RequestSongBroadcast.class));
        //切歌通知
        registerEventListener(ON_FINISH_SONG, RebroadcastEventListener.of(FinishSingBroadcast.class));
        //开始演唱通知
        registerEventListener(ON_START_SONG, RebroadcastEventListener.of(StartSingBroadcast.class));
    }

    private <T> void sendServerMessageOnNetwork(String eventName,
                                                String roomId,
                                                JsonObject content,
                                                Class<T> resultClass,
                                                IRequestCallback<T> callback) {
        sendServerMessage(eventName, roomId, content, new RTSRequest<>(callback, resultClass));
    }
}
