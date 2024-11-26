// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

/**
 * Anchor Lianmai end event
 */
public class AnchorLinkFinishEvent {
    @SerializedName("rtc_room_id")
    public String rtcRoomId;

    @NonNull
    @Override
    public String toString() {
        return "AudienceLinkFinishEvent{" +
                "rtcRoomId='" + rtcRoomId + '\'' +
                '}';
    }
}
