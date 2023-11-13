// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;


/**
 * Audience cancel the apply link event
 */
@RTSInform
public class AudienceLinkCancelEvent {
    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("user_id")
    public String userId;

    @NonNull
    @Override
    public String toString() {
        return "AudienceLinkCancelEvent{" +
                "rtcRoomId='" + rtcRoomId + '\'' +
                ", userId='" + userId + '\'' +
                '}';
    }
}
