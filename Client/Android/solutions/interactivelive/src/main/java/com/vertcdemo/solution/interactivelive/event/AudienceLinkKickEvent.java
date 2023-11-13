// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

/**
 * Host Disconnect Your link Event
 */
@RTSInform
public class AudienceLinkKickEvent {

    @SerializedName("linker_id")
    public String linkerId;

    @SerializedName("rtc_room_id")
    public String rtcRoomId;

    @SerializedName("room_id")
    public String rtsRoomId;

    @SerializedName("user_id")
    public String userId;

    @NonNull
    @Override
    public String toString() {
        return "AudienceLinkKickEvent{" +
                "linkerId='" + linkerId + '\'' +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", rtsRoomId='" + rtsRoomId + '\'' +
                ", userId='" + userId + '\'' +
                '}';
    }
}
