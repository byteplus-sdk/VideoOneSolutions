// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveRoleType;

import java.io.Serializable;


/**
 * User data model
 */
public class LiveUserInfo implements Serializable {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("user_id")
    public String userId;
    @SerializedName("user_name")
    public String userName;
    @SerializedName("user_role")
    @LiveRoleType
    public int role;
    @MediaStatus
    @SerializedName("mic")
    public int mic;
    @MediaStatus
    @SerializedName("camera")
    public int camera;
    /**
     * Additional information storage width and height
     * Format: "{\"width\":0,\"height\":0}"
     */
    @SerializedName("extra")
    public String extra;
    @LiveLinkMicStatus
    @SerializedName("linkmic_status")
    public int linkMicStatus;

    public boolean isMicOn() {
        return mic == MediaStatus.ON;
    }

    public boolean isCameraOn() {
        return camera == MediaStatus.ON;
    }

    @NonNull
    @Override
    public String toString() {
        return "LiveUserInfo{" +
                "roomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", role=" + role +
                ", micStatus=" + mic +
                ", cameraStatus=" + camera +
                ", extra='" + extra + '\'' +
                ", linkMicStatus=" + linkMicStatus +
                '}';
    }
}
