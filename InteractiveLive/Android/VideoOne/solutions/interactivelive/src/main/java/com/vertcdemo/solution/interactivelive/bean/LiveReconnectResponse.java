// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;
import com.vertcdemo.solution.interactivelive.feature.main.RoomStatus;

import java.util.Collections;
import java.util.List;

/**
 * The data model returned by the reconnection interface
 */
@RTSResponse
public class LiveReconnectResponse {

    @SerializedName("user")
    public LiveUserInfo userInfo;
    @SerializedName("reconnect_info")
    public ReconnectInfo recoverInfo;
    @RoomStatus
    @SerializedName("interact_status")
    public int interactStatus;

    @Nullable
    @SerializedName("interact_user_list")
    public List<LiveUserInfo> interactUserList;

    @NonNull
    public List<LiveUserInfo> getInteractUsers() {
        return interactUserList == null ? Collections.emptyList() : interactUserList;
    }

    @NonNull
    @Override
    public String toString() {
        return "LiveReconnectResponse{" +
                "userInfo=" + userInfo +
                ", recoverInfo=" + recoverInfo +
                ", interactStatus=" + interactStatus +
                ", interactUserList=" + interactUserList +
                '}';
    }
}
