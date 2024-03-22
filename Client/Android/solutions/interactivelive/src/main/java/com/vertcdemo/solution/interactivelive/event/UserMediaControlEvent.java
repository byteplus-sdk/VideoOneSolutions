// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.core.annotation.MediaStatus;

/**
 * Audience media status update event
 */
@RTSInform
public class UserMediaControlEvent {
    @SerializedName("guest_room_id")
    public String guestRoomId;
    @SerializedName("guest_user_id")
    public String guestUserId;
    @MediaStatus
    @SerializedName("mic")
    public int mic;
    @MediaStatus
    @SerializedName("camera")
    public int camera;

    @NonNull
    @Override
    public String toString() {
        return "UserMediaControlEvent{" +
                "guestRoomId='" + guestRoomId + '\'' +
                ", guestUserId='" + guestUserId + '\'' +
                ", mic=" + mic +
                ", camera=" + camera +
                '}';
    }
}
