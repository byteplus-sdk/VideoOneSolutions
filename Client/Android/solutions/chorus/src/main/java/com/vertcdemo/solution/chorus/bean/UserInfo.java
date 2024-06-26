// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.IntDef;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.SolutionDataManager;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class UserInfo implements Parcelable {

    public static final int USER_ROLE_HOST = 1;
    public static final int USER_ROLE_AUDIENCE = 2;
    @IntDef({USER_ROLE_HOST, USER_ROLE_AUDIENCE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface UserRole {
    }

    public static final int MIC_STATUS_OFF = 0;
    public static final int MIC_STATUS_ON = 1;
    @IntDef({MIC_STATUS_OFF, MIC_STATUS_ON})
    @Retention(RetentionPolicy.SOURCE)
    public @interface MicStatus {
    }

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("user_id")
    public String userId;
    @SerializedName("user_name")
    public String userName;

    @SerializedName("user_role")
    @UserRole
    public int userRole = USER_ROLE_AUDIENCE;

    @SerializedName("mic")
    public int mic;

    public UserInfo(){

    }

    protected UserInfo(Parcel in) {
        roomId = in.readString();
        userId = in.readString();
        userName = in.readString();
        userRole = in.readInt();
        mic = in.readInt();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(roomId);
        dest.writeString(userId);
        dest.writeString(userName);
        dest.writeInt(userRole);
        dest.writeInt(mic);
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

    public boolean isMicOn() {
        return mic != MIC_STATUS_OFF;
    }

    /**
     * 是否为房主
     * @return true 是房主
     */
    public boolean isHost() {
        return userRole == USER_ROLE_HOST;
    }

    public UserInfo deepCopy() {
        UserInfo info = new UserInfo();
        info.roomId = roomId;
        info.userId = userId;
        info.userName = userName;
        info.userRole = userRole;
        info.mic = mic;
        return info;
    }

    @Override
    public String toString() {
        return "VCUserInfo{" +
                "roomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", userRole=" + userRole +
                ", mic=" + mic +
                '}';
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
}
