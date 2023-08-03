// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

import java.util.List;

/**
 * The anchor responds to the connection invitation event
 */
@RTSInform
public class AnchorLinkReplyEvent {
    @SerializedName("invitee")
    public LiveUserInfo userInfo;
    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("reply_type")
    public int replyType;
    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("rtc_user_list")
    public List<LiveUserInfo> rtcUserList;

    @NonNull
    @Override
    public String toString() {
        return "AnchorLinkReplyEvent{" +
                "userInfo=" + userInfo +
                ", linkerId='" + linkerId + '\'' +
                ", replyType=" + replyType +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", rtcToken='" + rtcToken + '\'' +
                ", rtcUserList=" + rtcUserList +
                '}';
    }
}
