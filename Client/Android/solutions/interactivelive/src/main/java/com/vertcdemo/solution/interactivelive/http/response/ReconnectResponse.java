// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.http.response;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.ReconnectInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.feature.main.RoomStatus;

import java.util.Collections;
import java.util.List;

/**
 * The data model returned by the reconnection interface
 */
public class ReconnectResponse {

    @SerializedName("user")
    public LiveUserInfo userInfo;
    @SerializedName("reconnect_info")
    public ReconnectInfo recoverInfo;
    @LiveLinkMicStatus
    @SerializedName(value = "linkmic_status")
    public int linkMicStatus;

    @NonNull
    @Override
    public String toString() {
        return "ReconnectResponse{" +
                "userInfo=" + userInfo +
                ", recoverInfo=" + recoverInfo +
                ", linkMicStatus=" + linkMicStatus +
                '}';
    }

    @RoomStatus
    public int getRoomStatus() {
        switch (linkMicStatus) {
            case LiveLinkMicStatus.AUDIENCE_INTERACTING:
                return RoomStatus.AUDIENCE_LINK;
            case LiveLinkMicStatus.HOST_INTERACTING:
                return RoomStatus.PK;
            default:
                return RoomStatus.LIVE;
        }
    }

    @NonNull
    public List<LiveUserInfo> getLinkMicUsers() {
        return recoverInfo == null ? Collections.emptyList() : recoverInfo.getLinkMicUsers();
    }
}
