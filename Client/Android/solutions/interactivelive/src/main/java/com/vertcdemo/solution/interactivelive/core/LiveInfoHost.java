// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import androidx.annotation.NonNull;

class LiveInfoHost {
    public final String roomId;
    public final String userId;
    public final String pushUrl;

    public LiveInfoHost(String roomId, String userId, String pushUrl) {
        this.roomId = roomId;
        this.userId = userId;
        this.pushUrl = pushUrl;
    }

    public LiveInfoHost(String roomId, String userId) {
        this(roomId, userId, null);
    }

    public boolean match(String roomId, String userId) {
        return roomId != null && roomId.equals(this.roomId)
                && userId != null && userId.equals(this.userId);
    }

    @NonNull
    @Override
    public String toString() {
        return "LiveInfoHost{" +
                "roomId='" + roomId + '\'' +
                ", userId='" + userId + '\'' +
                ", pushUrl='" + pushUrl + '\'' +
                '}';
    }
}
