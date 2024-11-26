// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.FinishInteractType;

public abstract class InteractChangedBroadcast {

    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("seat_id")
    public int seatId;
    @SerializedName("type")
    @FinishInteractType
    public int type = FinishInteractType.HOST;

    public boolean isByHost() {
        return type == FinishInteractType.HOST;
    }

    public abstract boolean isJoin();

    public final boolean isFinish() {
        return !isJoin();
    }

    public String getUserId() {
        return userInfo.userId;
    }

    @NonNull
    @Override
    public String toString() {
        return "InteractChangedBroadcast{" +
                ", userInfo=" + userInfo +
                ", seatId=" + seatId +
                ", type=" + type +
                ", isJoin=" + isJoin() +
                '}';
    }

    public static class Join extends InteractChangedBroadcast {
        @Override
        public boolean isJoin() {
            return true;
        }
    }

    public static class Finish extends InteractChangedBroadcast {
        @Override
        public boolean isJoin() {
            return false;
        }
    }
}
