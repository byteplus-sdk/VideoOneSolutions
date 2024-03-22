// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;


import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatStatus;

public class SeatInfo implements Parcelable {
    @SerializedName("status")
    @SeatStatus
    public int status;
    @SerializedName("guest_info")
    public UserInfo userInfo;

    public SeatInfo() {
        status = SeatStatus.UNLOCKED;
    }

    protected SeatInfo(Parcel in) {
        status = in.readInt();
        userInfo = in.readParcelable(UserInfo.class.getClassLoader());
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeParcelable(userInfo, flags);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SeatInfo> CREATOR = new Creator<SeatInfo>() {
        @Override
        public SeatInfo createFromParcel(Parcel in) {
            return new SeatInfo(in);
        }

        @Override
        public SeatInfo[] newArray(int size) {
            return new SeatInfo[size];
        }
    };

    public boolean isLocked() {
        return status == SeatStatus.LOCKED;
    }

    public void setStatusAndUser(int status, UserInfo info) {
        this.status = status;
        this.userInfo = info;
    }

    public void clearUser() {
        this.userInfo = null;
    }

    public static SeatInfo byUserInfo(UserInfo userInfo) {
        SeatInfo seatInfo = new SeatInfo();
        seatInfo.userInfo = userInfo;
        return seatInfo;
    }

    @NonNull
    @Override
    public String toString() {
        return "VCSeatInfo{" +
                " status=" + status +
                ", userInfo=" + userInfo +
                '}';
    }
}
