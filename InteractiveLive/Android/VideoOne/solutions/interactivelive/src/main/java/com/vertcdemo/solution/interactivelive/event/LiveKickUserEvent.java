// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;

/**
 * kick out user events
 */
public class LiveKickUserEvent {

    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("user_name")
    public String userName;

    @Override
    public String toString() {
        return "LiveKickUserEvent{" +
                "linkerId='" + linkerId + '\'' +
                ", rtcRoomId='" + rtcRoomId + '\'' +
                ", userName='" + userName + '\'' +
                '}';
    }
}
