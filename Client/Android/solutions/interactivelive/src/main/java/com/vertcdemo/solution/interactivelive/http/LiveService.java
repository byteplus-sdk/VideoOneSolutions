// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.solution.interactivelive.http;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.SolutionHttpService;
import com.vertcdemo.core.http.callback.OnNext;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.http.response.CreateRoomResponse;
import com.vertcdemo.solution.interactivelive.http.response.FinishRoomResponse;
import com.vertcdemo.solution.interactivelive.http.response.GetAnchorListResponse;
import com.vertcdemo.solution.interactivelive.http.response.GetAudienceListResponse;
import com.vertcdemo.solution.interactivelive.http.response.GetRoomListResponse;
import com.vertcdemo.solution.interactivelive.http.response.JoinRoomResponse;
import com.vertcdemo.solution.interactivelive.http.response.LinkResponse;
import com.vertcdemo.solution.interactivelive.http.response.PermitAudienceLinkResponse;
import com.vertcdemo.solution.interactivelive.http.response.ReconnectResponse;

public class LiveService extends SolutionHttpService {
    private static final LiveService INSTANCE = new LiveService();

    public static LiveService get() {
        return INSTANCE;
    }

    private static final String CMD_CLEAR_USER = "liveClearUser";
    private static final String CMD_GET_ROOM_LIST = "liveGetActiveLiveRoomList";

    private static final String CMD_CREATE_LIVE = "liveCreateLive";
    private static final String CMD_START_LIVE = "liveStartLive";
    private static final String CMD_FINISH_LIVE = "liveFinishLive";

    private static final String CMD_JOIN_ROOM = "liveJoinLiveRoom";
    private static final String CMD_LEAVE_ROOM = "liveLeaveLiveRoom";

    private static final String CMD_LIVE_RECONNECT = "liveReconnect";

    private static final String CMD_SEND_MESSAGE = "liveSendMessage";

    private static final String CMD_GET_ANCHOR_LIST = "liveGetActiveAnchorList";
    private static final String CMD_GET_AUDIENCE_LIST = "liveGetAudienceList";

    private static final String CMD_MANAGE_GUEST_MEDIA = "liveManageGuestMedia";
    private static final String CMD_UPDATE_MEDIA_STATUS = "liveUpdateMediaStatus";
    private static final String CMD_UPDATE_RESOLUTION = "liveUpdateResolution";

    private static final String CMD_AUDIENCE_LINK_MIC_INVITE = "liveAudienceLinkmicInvite";
    private static final String CMD_AUDIENCE_LINK_MIC_PERMIT = "liveAudienceLinkmicPermit";
    private static final String CMD_AUDIENCE_LINK_MIC_KICK = "liveAudienceLinkmicKick";
    private static final String CMD_AUDIENCE_LINK_MIC_FINISH = "liveAudienceLinkmicFinish";
    private static final String CMD_AUDIENCE_LINK_MIC_APPLY = "liveAudienceLinkmicApply";
    private static final String CMD_AUDIENCE_LINK_MIC_REPLY = "liveAudienceLinkmicReply";
    private static final String CMD_AUDIENCE_LINK_MIC_LEAVE = "liveAudienceLinkmicLeave";
    private static final String CMD_AUDIENCE_LINK_MIC_CANCEL = "liveAudienceLinkmicCancel";

    private static final String CMD_ANCHOR_LINK_MIC_INVITE = "liveAnchorLinkmicInvite";
    private static final String CMD_ANCHOR_LINK_MIC_REPLY = "liveAnchorLinkmicReply";
    private static final String CMD_ANCHOR_LINK_MIC_FINISH = "liveAnchorLinkmicFinish";

    private LiveService() {

    }

    public void clearUser(@NonNull Runnable next) {
        JsonObject params = getCommonParams();

        request(CMD_CLEAR_USER, params, OnNext.of(next));
    }

    public void getRoomList(Callback<GetRoomListResponse> callback) {
        JsonObject params = getCommonParams();

        request(CMD_GET_ROOM_LIST, params, GetRoomListResponse.class, callback);
    }

    public void createLive(Callback<CreateRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        request(CMD_CREATE_LIVE, params, CreateRoomResponse.class, callback);
    }

    public void startLive(String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        request(CMD_START_LIVE, params, callback);
    }

    public void finishLive(String roomId, Callback<FinishRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_FINISH_LIVE, params, FinishRoomResponse.class, callback);
    }

    /**
     * Audience joins a live room.
     *
     * @param roomId   The room id to be joined
     * @param callback callback
     */
    public void joinRoom(String roomId, Callback<JoinRoomResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        request(CMD_JOIN_ROOM, params, JoinRoomResponse.class, callback);
    }

    /**
     * Audience leaves a live room.
     *
     * @param roomId The room id to be leave
     */
    public void leaveRoom(String roomId) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        request(CMD_LEAVE_ROOM, params, OnNext.empty());
    }

    public void reconnect(String roomId, Callback<ReconnectResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        request(CMD_LIVE_RECONNECT, params, ReconnectResponse.class, callback);
    }

    public void sendMessage(String roomId, MessageBody body) {
        sendMessage(roomId, body, OnNext.empty());
    }

    public void sendMessage(String roomId, MessageBody body, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("message", GsonUtils.gson().toJson(body));

        request(CMD_SEND_MESSAGE, params, callback);
    }

    public void getAnchorList(Callback<GetAnchorListResponse> callback) {
        JsonObject params = getCommonParams();
        request(CMD_GET_ANCHOR_LIST, params, GetAnchorListResponse.class, callback);
    }

    public void getAudienceList(String roomId, Callback<GetAudienceListResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        request(CMD_GET_AUDIENCE_LIST, params, GetAudienceListResponse.class, callback);
    }

    public void manageGuestMedia(String hostRoomId, String hostUserId,
                                 String guestRoomId, String guestUserId,
                                 @MediaStatus int camera,
                                 @MediaStatus int mic) {
        JsonObject params = getCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("guest_room_id", guestRoomId);
        params.addProperty("guest_user_id", guestUserId);
        params.addProperty("mic", mic);
        params.addProperty("camera", camera);

        request(CMD_MANAGE_GUEST_MEDIA, params, OnNext.empty());
    }

    public void updateMediaStatus(String roomId,
                                  @MediaStatus int micStatus,
                                  @MediaStatus int cameraStatus) {
        updateMediaStatus(roomId, micStatus, cameraStatus, OnNext.empty());
    }

    public void updateMediaStatus(String roomId,
                                  @MediaStatus int micStatus,
                                  @MediaStatus int cameraStatus,
                                  Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("mic", micStatus);
        params.addProperty("camera", cameraStatus);
        request(CMD_UPDATE_MEDIA_STATUS, params, callback);
    }

    public void updateResolution(String roomId, int width, int height) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("width", width);
        params.addProperty("height", height);
        request(CMD_UPDATE_RESOLUTION, params, OnNext.empty());
    }

    public void inviteAudienceLink(String hostRoomId, String hostUserId,
                                   String audienceRoomId, String audienceUserId,
                                   String extra,
                                   Callback<LinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("extra", extra);

        request(CMD_AUDIENCE_LINK_MIC_INVITE, params, LinkResponse.class, callback);
    }

    public void permitAudienceLink(String linkerId,
                                   String hostRoomId, String hostUserId,
                                   String audienceRoomId, String audienceUserId,
                                   int permitType,
                                   Callback<PermitAudienceLinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("permit_type", permitType);

        request(CMD_AUDIENCE_LINK_MIC_PERMIT, params, PermitAudienceLinkResponse.class, callback);
    }

    public void kickAudienceLink(String hostRoomId, String hostUserId,
                                 String audienceRoomId, String audienceUserId,
                                 Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);

        request(CMD_AUDIENCE_LINK_MIC_KICK, params, callback);
    }

    public void finishAudienceLink(String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_AUDIENCE_LINK_MIC_FINISH, params, callback);
    }

    public void applyAudienceLink(String roomId, Callback<LinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("room_id", roomId);

        request(CMD_AUDIENCE_LINK_MIC_APPLY, params, LinkResponse.class, callback);
    }

    public void replyAudienceLink(String linkerId, String roomId, int replyType, Callback<LinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);
        params.addProperty("reply_type", replyType);

        request(CMD_AUDIENCE_LINK_MIC_REPLY, params, LinkResponse.class, callback);
    }

    public void leaveAudienceLink(String linkerId, String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);

        request(CMD_AUDIENCE_LINK_MIC_LEAVE, params, callback);
    }

    public void cancelAudienceLink(String linkerId, String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);

        request(CMD_AUDIENCE_LINK_MIC_CANCEL, params, callback);
    }

    public void inviteAnchorLink(
            String inviterRoomId, String inviterUserId,
            String inviteeRoomId, String inviteeUserId,
            String extra,
            Callback<LinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("inviter_room_id", inviterRoomId);
        params.addProperty("inviter_user_id", inviterUserId);
        params.addProperty("invitee_room_id", inviteeRoomId);
        params.addProperty("invitee_user_id", inviteeUserId);
        params.addProperty("extra", extra);

        request(CMD_ANCHOR_LINK_MIC_INVITE, params, LinkResponse.class, callback);
    }

    public void replyAnchorLink(String linkerId,
                                String inviterRoomId, String inviterUserId,
                                String inviteeRoomId, String inviteeUserId,
                                int replyType,
                                Callback<LinkResponse> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("inviter_room_id", inviterRoomId);
        params.addProperty("inviter_user_id", inviterUserId);
        params.addProperty("invitee_room_id", inviteeRoomId);
        params.addProperty("invitee_user_id", inviteeUserId);
        params.addProperty("reply_type", replyType);

        request(CMD_ANCHOR_LINK_MIC_REPLY, params, LinkResponse.class, callback);
    }

    public void finishAnchorLink(String linkerId, String roomId, Callback<Void> callback) {
        JsonObject params = getCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);

        request(CMD_ANCHOR_LINK_MIC_FINISH, params, callback);
    }
}
