// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;

import com.vertcdemo.core.event.ClearUserEvent;
import com.vertcdemo.core.rts.RTSBaseClient;
import com.vertcdemo.solution.chorus.bean.FinishLiveInform;
import com.vertcdemo.solution.chorus.bean.FinishSingInform;
import com.vertcdemo.solution.chorus.bean.MessageInform;
import com.vertcdemo.solution.chorus.bean.PickedSongInform;
import com.vertcdemo.solution.chorus.bean.StartSingInform;
import com.vertcdemo.solution.chorus.bean.WaitSingInform;
import com.vertcdemo.solution.chorus.event.AudienceChangedEvent;

public class ChorusRTSClient extends RTSBaseClient {
    // 结束直播通知
    private static final String ON_FINISH_LIVE = "owcOnFinishLive";
    // 观众进房通知
    private static final String ON_AUDIENCE_JOIN_ROOM = "owcOnAudienceJoinRoom";
    // 观众离房通知
    private static final String ON_AUDIENCE_LEAVE_ROOM = "owcOnAudienceLeaveRoom";
    // 聊天区消息
    private static final String ON_MESSAGE = "owcOnMessage";
    private static final String ON_MEDIA_OPERATE = "owcOnMediaOperate";
    // 互踢: 用户在其它端登陆时，会给前一个登陆端下发该通知，收到后不用调用退房接口，直接关闭即可
    private static final String ON_CLEAR_USER = "owcOnClearUser";
    // 点歌通知
    private static final String ON_PICK_SONG = "owcOnRequestSong";
    // 等待演唱
    private static final String ON_WAIT_SING = "owcOnWaitSing";
    // 开始演唱
    private static final String ON_START_SING = "owcOnStartSing";
    // 演唱结束通知
    private static final String ON_FINISH_SING = "owcOnFinishSing";

    public ChorusRTSClient() {
        registerEventType(ON_MESSAGE, MessageInform.class);
        registerEventType(ON_CLEAR_USER, ClearUserEvent.class);
        registerEventType(ON_AUDIENCE_JOIN_ROOM, AudienceChangedEvent.Join.class);
        registerEventType(ON_AUDIENCE_LEAVE_ROOM, AudienceChangedEvent.Leave.class);
        registerEventType(ON_FINISH_LIVE, FinishLiveInform.class);
        registerEventType(ON_START_SING, StartSingInform.class);
        registerEventType(ON_WAIT_SING, WaitSingInform.class);
        registerEventType(ON_FINISH_SING, FinishSingInform.class);
        registerEventType(ON_PICK_SONG, PickedSongInform.class);
    }
}
