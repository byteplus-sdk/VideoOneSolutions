// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core;

import com.vertcdemo.core.event.ClearUserEvent;
import com.vertcdemo.core.rts.RTSBaseClient;
import com.vertcdemo.solution.ktv.event.AudienceApplyBroadcast;
import com.vertcdemo.solution.ktv.event.AudienceChangedEvent;
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
    // 观众进房通知
    private static final String ON_AUDIENCE_JOIN_ROOM = "ktvOnAudienceJoinRoom";
    // 观众离房通知
    private static final String ON_AUDIENCE_LEAVE_ROOM = "ktvOnAudienceLeaveRoom";
    // 结束直播通知
    private static final String ON_FINISH_LIVE = "ktvOnFinishLive";
    // 加入互动通知
    private static final String ON_JOIN_INTERACT = "ktvOnJoinInteract";
    // 结束互动通知
    private static final String ON_FINISH_INTERACT = "ktvOnFinishInteract";
    private static final String ON_SEAT_CHANGE = "ktvOnSeatStatusChange";
    // 麦克风状态变化
    private static final String ON_MEDIA_STATUS_CHANGE = "ktvOnMediaStatusChange";
    // 聊天区消息
    private static final String ON_MESSAGE = "ktvOnMessage";
    // 互动邀请
    private static final String ON_INVITE_INTERACT = "ktvOnInviteInteract";
    // 互动申请
    private static final String ON_APPLY_INTERACT = "ktvOnApplyInteract";
    // 邀请结果:接受/拒绝，通知主播
    private static final String ON_INVITE_RESULT = "ktvOnInviteResult";
    // 麦克风操作:主播mute/unmute嘉宾麦克风
    private static final String ON_MEDIA_OPERATE = "ktvOnMediaOperate";
    // 互踢: 用户在其它端登陆时，会给前一个登陆端下发该通知，收到后不用调用退房接口，直接关闭即可
    private static final String ON_CLEAR_USER = "ktvOnClearUser";
    // 点歌通知
    private static final String ON_REQUEST_SONG = "ktvOnRequestSong";
    // 切歌通知
    private static final String ON_FINISH_SONG = "ktvOnFinishSing";
    // 开始演唱通知
    private static final String ON_START_SONG = "ktvOnStartSing";

    public KTVRTSClient() {
        registerEventType(ON_AUDIENCE_JOIN_ROOM, AudienceChangedEvent.Join.class);
        registerEventType(ON_AUDIENCE_LEAVE_ROOM, AudienceChangedEvent.Leave.class);
        registerEventType(ON_FINISH_LIVE, FinishLiveBroadcast.class);
        registerEventType(ON_JOIN_INTERACT, InteractChangedBroadcast.Join.class);
        registerEventType(ON_FINISH_INTERACT, InteractChangedBroadcast.Finish.class);
        registerEventType(ON_SEAT_CHANGE, SeatChangedBroadcast.class);
        registerEventType(ON_MEDIA_STATUS_CHANGE, MediaChangedBroadcast.class);
        registerEventType(ON_MESSAGE, MessageBroadcast.class);
        registerEventType(ON_INVITE_INTERACT, ReceivedInteractBroadcast.class);
        registerEventType(ON_APPLY_INTERACT, AudienceApplyBroadcast.class);
        registerEventType(ON_INVITE_RESULT, InteractResultBroadcast.class);
        registerEventType(ON_MEDIA_OPERATE, MediaOperateBroadcast.class);
        registerEventType(ON_CLEAR_USER, ClearUserEvent.class);
        registerEventType(ON_REQUEST_SONG, RequestSongBroadcast.class);
        registerEventType(ON_FINISH_SONG, FinishSingBroadcast.class);
        registerEventType(ON_START_SONG, StartSingBroadcast.class);
    }
}
