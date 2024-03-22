// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserRole;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;

public class UserInfo implements Parcelable {

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("user_id")
    public String userId;
    @SerializedName("user_name")
    public String userName;
    @SerializedName("user_role")
    @UserRole
    public int userRole = UserRole.AUDIENCE;
    @SerializedName("status")
    @UserStatus
    public int userStatus = UserStatus.NORMAL;
    @SerializedName("mic")
    @MediaStatus
    public int mic;
    @SerializedName("camera")
    @MediaStatus
    public int camera;

    public boolean isMicOn() {
        return mic == MediaStatus.ON;
    }

    public void setMicStatus(boolean value) {
        mic = value ? MediaStatus.ON : MediaStatus.OFF;
    }

    public boolean isCameraOn() {
        return camera == MediaStatus.ON;
    }

    public boolean isHost() {
        return userRole == UserRole.HOST;
    }

    public UserInfo() {

    }

    public boolean isInteract() {
        return userStatus == UserStatus.INTERACT;
    }

    public UserInfo(String userId, String userName) {
        this.userId = userId;
        this.userName = userName;
    }

    public static UserInfo self() {
        return new UserInfo(
                SolutionDataManager.ins().getUserId(),
                SolutionDataManager.ins().getUserName()
        );
    }

    protected UserInfo(Parcel in) {
        roomId = in.readString();
        userId = in.readString();
        userName = in.readString();
        userRole = in.readInt();
        userStatus = in.readInt();
        mic = in.readInt();
        camera = in.readInt();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(roomId);
        dest.writeString(userId);
        dest.writeString(userName);
        dest.writeInt(userRole);
        dest.writeInt(userStatus);
        dest.writeInt(mic);
        dest.writeInt(camera);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<UserInfo> CREATOR = new Creator<UserInfo>() {
        @Override
        public UserInfo createFromParcel(Parcel in) {
            return new UserInfo(in);
        }

        @Override
        public UserInfo[] newArray(int size) {
            return new UserInfo[size];
        }
    };

    @Override
    @NonNull
    public String toString() {
        return "UserInfo{" +
                "requireRoomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", userRole=" + userRole +
                ", userStatus=" + userStatus +
                ", mic=" + mic +
                '}';
    }

    public void updateBy(UserInfo other) {
        this.userRole = other.userRole;
        this.userStatus = other.userStatus;
        this.mic = other.mic;
        this.camera = other.camera;
    }
}
