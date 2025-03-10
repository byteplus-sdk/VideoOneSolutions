// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.Event;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

import java.util.List;


/**
 * Connection state update event
 */
public abstract class AudienceLinkStatusEvent {

    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("user_list")
    public List<LiveUserInfo> userList;
    @SerializedName("user_id")
    public String userId;

    public abstract boolean isJoin();

    @Override
    public String toString() {
        return "AudienceLinkStatusEvent{" +
                "linkerId='" + linkerId + '\'' +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", userList=" + userList +
                ", userId='" + userId + '\'' +
                '}';
    }

    @Event
    public static final class Join extends AudienceLinkStatusEvent {
        @Override
        public boolean isJoin() {
            return true;
        }
    }

    @Event
    public static final class Leave extends AudienceLinkStatusEvent {
        @Override
        public boolean isJoin() {
            return false;
        }
    }
}
