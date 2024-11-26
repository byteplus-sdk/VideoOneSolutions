// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import com.vertcdemo.core.rts.RTSBaseClient;
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

public class LiveRTSClient extends RTSBaseClient {

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

    public LiveRTSClient() {
        registerEventType(ON_AUDIENCE_JOIN_ROOM, LiveRTSUserEvent.Join.class);
        registerEventType(ON_AUDIENCE_LEAVE_ROOM, LiveRTSUserEvent.Leave.class);
        registerEventType(ON_FINISH_LIVE, LiveFinishEvent.class);
        registerEventType(ON_LINK_MIC_STATUS, LinkMicStatusEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_JOIN, AudienceLinkStatusEvent.Join.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_LEAVE, AudienceLinkStatusEvent.Leave.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_FINISH, AudienceLinkFinishEvent.class);
        registerEventType(ON_MEDIA_CHANGE, UserMediaChangedEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_INVITE, AudienceLinkInviteEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_APPLY, AudienceLinkApplyEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_CANCEL, AudienceLinkCancelEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_REPLY, AudienceLinkReplyEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_PERMIT, AudienceLinkPermitEvent.class);
        registerEventType(ON_AUDIENCE_LINK_MIC_KICK, AudienceLinkKickEvent.class);
        registerEventType(ON_ANCHOR_LINK_MIC_INVITE, AnchorLinkInviteEvent.class);
        registerEventType(ON_ANCHOR_LINK_MIC_REPLY, AnchorLinkReplyEvent.class);
        registerEventType(ON_ANCHOR_LINK_MIC_FINISH, AnchorLinkFinishEvent.class);
        registerEventType(ON_MANAGER_GUEST_MEDIA, UserMediaControlEvent.class);
        registerEventType(ON_MESSAGE_SEND, MessageEvent.class);
    }
}
