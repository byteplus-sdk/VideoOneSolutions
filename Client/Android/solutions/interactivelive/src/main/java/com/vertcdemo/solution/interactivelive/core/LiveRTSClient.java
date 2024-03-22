// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.common.RebroadcastEventListener;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.RequestCallbackAdapter;
import com.vertcdemo.core.net.rts.RTSBaseClient;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.core.net.rts.RTSRequest;
import com.vertcdemo.solution.interactivelive.bean.LiveInviteResponse;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkInviteEvent;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkReplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkCancelEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkInviteEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkKickEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkPermitEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkReplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LinkMicStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LiveFinishEvent;
import com.vertcdemo.solution.interactivelive.event.LiveRTSUserEvent;
import com.vertcdemo.solution.interactivelive.event.MessageEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaControlEvent;
import com.vertcdemo.solution.interactivelive.bean.CreateLiveRoomResponse;
import com.vertcdemo.solution.interactivelive.bean.GetActiveAnchorListResponse;
import com.vertcdemo.solution.interactivelive.bean.GetAudienceListResponse;
import com.vertcdemo.solution.interactivelive.bean.JoinLiveRoomResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveAnchorPermitAudienceResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveFinishResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveReconnectResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveReplyResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomListResponse;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;

public class LiveRTSClient extends RTSBaseClient {

    private static final String CMD_LIVE_GET_ACTIVE_LIVE_ROOM_LIST = "liveGetActiveLiveRoomList";
    private static final String CMD_LIVE_CLEAR_USER = "liveClearUser";
    private static final String CMD_LIVE_RECONNECT = "liveReconnect";
    private static final String CMD_LIVE_UPDATE_MEDIA_STATUS = "liveUpdateMediaStatus";

    private static final String CMD_LIVE_CREATE_LIVE = "liveCreateLive";
    private static final String CMD_LIVE_START_LIVE = "liveStartLive";
    private static final String CMD_LIVE_UPDATE_RESOLUTION = "liveUpdateResolution";
    private static final String CMD_LIVE_GET_ACTIVE_ANCHOR_LIST = "liveGetActiveAnchorList";
    private static final String CMD_LIVE_GET_AUDIENCE_LIST = "liveGetAudienceList";
    private static final String CMD_LIVE_MANAGE_GUEST_MEDIA = "liveManageGuestMedia";
    private static final String CMD_LIVE_FINISH_LIVE = "liveFinishLive";

    private static final String CMD_LIVE_JOIN_LIVE_ROOM = "liveJoinLiveRoom";
    private static final String CMD_LIVE_LEAVE_LIVE_ROOM = "liveLeaveLiveRoom";

    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_INVITE = "liveAudienceLinkmicInvite";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_PERMIT = "liveAudienceLinkmicPermit";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_KICK = "liveAudienceLinkmicKick";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_FINISH = "liveAudienceLinkmicFinish";
    private static final String CMD_LIVE_ANCHOR_LINK_MIC_INVITE = "liveAnchorLinkmicInvite";
    private static final String CMD_LIVE_ANCHOR_LINK_MIC_REPLY = "liveAnchorLinkmicReply";
    private static final String CMD_LIVE_ANCHOR_LINK_MIC_FINISH = "liveAnchorLinkmicFinish";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_APPLY = "liveAudienceLinkmicApply";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_REPLY = "liveAudienceLinkmicReply";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_LEAVE = "liveAudienceLinkmicLeave";
    private static final String CMD_LIVE_AUDIENCE_LINK_MIC_CANCEL = "liveAudienceLinkmicCancel";
    private static final String CMD_LIVE_SEND_MESSAGE = "liveSendMessage";

    private static final String ON_AUDIENCE_JOIN_ROOM = "liveOnAudienceJoinRoom";
    private static final String ON_AUDIENCE_LEAVE_ROOM = "liveOnAudienceLeaveRoom";
    private static final String ON_FINISH_LIVE = "liveOnFinishLive";
    private static final String ON_LINK_MIC_STATUS = "liveOnLinkmicStatus";
    private static final String ON_AUDIENCE_LINK_MIC_JOIN = "liveOnAudienceLinkmicJoin";
    private static final String ON_AUDIENCE_LINK_MIC_LEAVE = "liveOnAudienceLinkmicLeave";
    private static final String ON_AUDIENCE_LINK_MIC_FINISH = "liveOnAudienceLinkmicFinish";
    private static final String ON_MEDIA_CHANGE = "liveOnMediaChange";
    private static final String ON_AUDIENCE_LINK_MIC_INVITE = "liveOnAudienceLinkmicInvite";
    private static final String ON_AUDIENCE_LINK_MIC_APPLY = "liveOnAudienceLinkmicApply";
    private static final String ON_AUDIENCE_LINK_MIC_CANCEL = "liveOnAudienceLinkmicCancel";
    private static final String ON_AUDIENCE_LINK_MIC_REPLY = "liveOnAudienceLinkmicReply";
    private static final String ON_AUDIENCE_LINK_MIC_PERMIT = "liveOnAudienceLinkmicPermit";
    private static final String ON_AUDIENCE_LINK_MIC_KICK = "liveOnAudienceLinkmicKick";
    private static final String ON_ANCHOR_LINK_MIC_INVITE = "liveOnAnchorLinkmicInvite";
    private static final String ON_ANCHOR_LINK_MIC_REPLY = "liveOnAnchorLinkmicReply";
    private static final String ON_ANCHOR_LINK_MIC_FINISH = "liveOnAnchorLinkmicFinish";
    private static final String ON_MANAGER_GUEST_MEDIA = "liveOnManageGuestMedia";
    private static final String ON_MESSAGE_SEND = "liveOnMessageSend";

    public LiveRTSClient(@NonNull RTCVideo rtcVideo, @NonNull RTSInfo rtsInfo) {
        super(rtcVideo, rtsInfo);
        initEventListener();
    }

    private void initEventListener() {
        registerEventListener(ON_AUDIENCE_JOIN_ROOM,
                RebroadcastEventListener.of(LiveRTSUserEvent.Join.class));
        registerEventListener(ON_AUDIENCE_LEAVE_ROOM,
                RebroadcastEventListener.of(LiveRTSUserEvent.Leave.class));
        registerEventListener(ON_FINISH_LIVE, RebroadcastEventListener.of(LiveFinishEvent.class));
        registerEventListener(ON_LINK_MIC_STATUS,
                RebroadcastEventListener.of(LinkMicStatusEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_JOIN,
                RebroadcastEventListener.of(AudienceLinkStatusEvent.Join.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_LEAVE,
                RebroadcastEventListener.of(AudienceLinkStatusEvent.Leave.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_FINISH,
                RebroadcastEventListener.of(AudienceLinkFinishEvent.class));
        registerEventListener(ON_MEDIA_CHANGE,
                RebroadcastEventListener.of(UserMediaChangedEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_INVITE,
                RebroadcastEventListener.of(AudienceLinkInviteEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_APPLY,
                RebroadcastEventListener.of(AudienceLinkApplyEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_CANCEL,
                RebroadcastEventListener.of(AudienceLinkCancelEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_REPLY,
                RebroadcastEventListener.of(AudienceLinkReplyEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_PERMIT,
                RebroadcastEventListener.of(AudienceLinkPermitEvent.class));
        registerEventListener(ON_AUDIENCE_LINK_MIC_KICK,
                RebroadcastEventListener.of(AudienceLinkKickEvent.class));
        registerEventListener(ON_ANCHOR_LINK_MIC_INVITE,
                RebroadcastEventListener.of(AnchorLinkInviteEvent.class));
        registerEventListener(ON_ANCHOR_LINK_MIC_REPLY,
                RebroadcastEventListener.of(AnchorLinkReplyEvent.class));
        registerEventListener(ON_ANCHOR_LINK_MIC_FINISH,
                RebroadcastEventListener.of(AnchorLinkFinishEvent.class));
        registerEventListener(ON_MANAGER_GUEST_MEDIA,
                RebroadcastEventListener.of(UserMediaControlEvent.class));

        registerEventListener(ON_MESSAGE_SEND, RebroadcastEventListener.of(MessageEvent.class));
    }
    public void requestLiveRoomList(IRequestCallback<LiveRoomListResponse> callback) {
        JsonObject params = createCommonParams();
        sendServerMessageOnNetwork(CMD_LIVE_GET_ACTIVE_LIVE_ROOM_LIST,"", params, LiveRoomListResponse.class, callback);
    }

    public void requestLiveClearUser(Runnable next) {
        JsonObject params = createCommonParams();
        sendServerMessageOnNetwork(CMD_LIVE_CLEAR_USER, "", params, Void.class,
                RequestCallbackAdapter.create(next));
    }

    public void requestLiveReconnect(String roomId,
                                     IRequestCallback<LiveReconnectResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_RECONNECT, roomId, params, LiveReconnectResponse.class, callback);
    }

    public void updateMediaStatus(String roomId, @MediaStatus int micStatus,
                                  @MediaStatus int cameraStatus,
                                  IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("mic", micStatus);
        params.addProperty("camera", cameraStatus);
        sendServerMessageOnNetwork(CMD_LIVE_UPDATE_MEDIA_STATUS, roomId, params, LiveResponse.class, callback);
    }
    public void requestCreateLiveRoom(IRequestCallback<CreateLiveRoomResponse> callback) {
        JsonObject params = createCommonParams();
        sendServerMessageOnNetwork(CMD_LIVE_CREATE_LIVE, "", params, CreateLiveRoomResponse.class, callback);
    }

    public void updateResolution(String roomId, int width, int height,
                                 IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("width", width);
        params.addProperty("height", height);
        sendServerMessageOnNetwork(CMD_LIVE_UPDATE_RESOLUTION, roomId, params, LiveResponse.class, callback);
    }

    public void requestStartLive(String roomId, IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_START_LIVE, roomId, params, LiveResponse.class, callback);
    }

    public void requestActiveHostList(IRequestCallback<GetActiveAnchorListResponse> callback) {
        JsonObject params = createCommonParams();
        sendServerMessageOnNetwork(CMD_LIVE_GET_ACTIVE_ANCHOR_LIST,"", params, GetActiveAnchorListResponse.class, callback);
    }

    public void requestAudienceList(String roomId,
                                    IRequestCallback<GetAudienceListResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_GET_AUDIENCE_LIST, roomId, params, GetAudienceListResponse.class, callback);
    }

    public void requestManageGuest(String hostRoomId, String hostUserId, String guestRoomId,
                                   String guestUserId, @MediaStatus int camera,
                                   @MediaStatus int mic,
                                   IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("guest_room_id", guestRoomId);
        params.addProperty("guest_user_id", guestUserId);
        params.addProperty("mic", mic);
        params.addProperty("camera", camera);
        sendServerMessageOnNetwork(CMD_LIVE_MANAGE_GUEST_MEDIA, hostRoomId, params, LiveResponse.class, callback);
    }

    public void requestFinishLive(String roomId, IRequestCallback<LiveFinishResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_FINISH_LIVE, roomId, params, LiveFinishResponse.class, callback);
    }
    public void requestJoinLiveRoom(String roomId,
                                    IRequestCallback<JoinLiveRoomResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_JOIN_LIVE_ROOM, roomId, params, JoinLiveRoomResponse.class, callback);
    }

    public void requestLeaveLiveRoom(String roomId, IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_LEAVE_LIVE_ROOM, roomId, params, LiveResponse.class, callback);
    }

    public void inviteAudienceByHost(String hostRoomId, String hostUserId, String audienceRoomId,
                                     String audienceUserId, String extra,
                                     IRequestCallback<LiveInviteResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("extra", extra);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_INVITE, hostRoomId, params, LiveInviteResponse.class, callback);
    }

    public void replyAudienceRequestByHost(String linkerId, String hostRoomId, String hostUserId,
                                           String audienceRoomId, String audienceUserId,
                                           int permitType,
                                           IRequestCallback<LiveAnchorPermitAudienceResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);
        params.addProperty("permit_type", permitType);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_PERMIT, hostRoomId, params, LiveAnchorPermitAudienceResponse.class,
                callback);
    }

    public void kickAudienceByHost(String hostRoomId, String hostUserId, String audienceRoomId,
                                   String audienceUserId, IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("host_room_id", hostRoomId);
        params.addProperty("host_user_id", hostUserId);
        params.addProperty("audience_room_id", audienceRoomId);
        params.addProperty("audience_user_id", audienceUserId);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_KICK, hostRoomId, params, LiveResponse.class, callback);
    }

    public void finishAudienceLinkByHost(String roomId, IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_FINISH, roomId, params, LiveResponse.class, callback);
    }

    public void inviteHostByHost(String inviterRoomId, String inviterUserId, String inviteeRoomId
            , String inviteeUserId, String extra, IRequestCallback<LiveInviteResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("inviter_room_id", inviterRoomId);
        params.addProperty("inviter_user_id", inviterUserId);
        params.addProperty("invitee_room_id", inviteeRoomId);
        params.addProperty("invitee_user_id", inviteeUserId);
        params.addProperty("extra", extra);
        sendServerMessageOnNetwork(CMD_LIVE_ANCHOR_LINK_MIC_INVITE, inviterRoomId, params, LiveInviteResponse.class, callback);
    }

    public void replyHostInviteeByHost(String linkerId, String inviterRoomId,
                                       String inviterUserId, String inviteeRoomId,
                                       String inviteeUserId, int replyType,
                                       IRequestCallback<LiveInviteResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("inviter_room_id", inviterRoomId);
        params.addProperty("inviter_user_id", inviterUserId);
        params.addProperty("invitee_room_id", inviteeRoomId);
        params.addProperty("invitee_user_id", inviteeUserId);
        params.addProperty("reply_type", replyType);
        sendServerMessageOnNetwork(CMD_LIVE_ANCHOR_LINK_MIC_REPLY, inviterRoomId, params, LiveInviteResponse.class, callback);
    }

    public void finishHostLink(String linkerId, String roomId,
                               IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_ANCHOR_LINK_MIC_FINISH, roomId, params, LiveResponse.class, callback);
    }

    public void requestLinkByAudience(String roomId,
                                      IRequestCallback<LiveInviteResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_APPLY, roomId, params, LiveInviteResponse.class, callback);
    }

    public void requestCancelApplyLinkByAudience(String linkerId,
                                                 String roomId,
                                                 IRequestCallback<Void> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("linker_id", linkerId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_CANCEL, roomId, params, Void.class, callback);
    }

    public void replyHostInviterByAudience(String linkerId, String roomId, int replyType,
                                           IRequestCallback<LiveReplyResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);
        params.addProperty("reply_type", replyType);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_REPLY, roomId, params, LiveReplyResponse.class, callback);
    }

    public void finishAudienceLinkByAudience(String linkerId, String roomId,
                                             IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("linker_id", linkerId);
        params.addProperty("room_id", roomId);
        sendServerMessageOnNetwork(CMD_LIVE_AUDIENCE_LINK_MIC_LEAVE, roomId, params, LiveResponse.class, callback);
    }

    public void sendMessage(String roomId, MessageBody body) {
        sendMessage(roomId, body, null);
    }

    public void sendMessage(String roomId,
                            MessageBody body,
                            IRequestCallback<LiveResponse> callback) {
        JsonObject params = createCommonParams();
        params.addProperty("room_id", roomId);
        params.addProperty("message", GsonUtils.gson().toJson(body));
        sendServerMessageOnNetwork(CMD_LIVE_SEND_MESSAGE, roomId, params, LiveResponse.class, callback);
    }

    private <T> void sendServerMessageOnNetwork(String eventName,
                                                String roomId,
                                                JsonObject content,
                                                Class<T> resultClass,
                                                IRequestCallback<T> callback) {
        sendServerMessage(eventName, roomId, content, new RTSRequest<>(callback, resultClass));
    }
}
