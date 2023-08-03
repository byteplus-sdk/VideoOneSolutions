// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.interactivelive.core.annotation.MediaStatus;

/**
 * Media state change event
 */
@RTSInform
public class UserMediaChangedEvent {

    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("user_id")
    public String userId;
    @SerializedName("operator_user_id")
    public String operatorUserId;
    @SerializedName("camera")
    @MediaStatus
    public int camera;
    @SerializedName("mic")
    @MediaStatus
    public int mic;

    public UserMediaChangedEvent() {

    }

    public UserMediaChangedEvent(String roomId, String userId, String hostId,
                                 @MediaStatus int mic, @MediaStatus int camera) {
        this.rtcRoomId = roomId;
        this.userId = userId;
        this.operatorUserId = hostId;
        this.mic = mic;
        this.camera = camera;
    }

    public boolean isMicOn() {
        return mic == MediaStatus.ON;
    }

    public boolean isCameraOn() {
        return camera == MediaStatus.ON;
    }

    @NonNull
    @Override
    public String toString() {
        return "UserMediaChangedEvent{" +
                "rtcRoomId='" + rtcRoomId + '\'' +
                ", userId='" + userId + '\'' +
                ", operatorUserId='" + operatorUserId + '\'' +
                ", camera=" + camera +
                ", mic=" + mic +
                '}';
    }
}
