// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.ktv.bean.UserInfo;

public class MediaChangedBroadcast {

    @SerializedName("mic")
    @MediaStatus
    public int mic;
    @SerializedName("user_info")
    public UserInfo userInfo;

    @Override
    public String toString() {
        return "MediaChangedBroadcast{" +
                "mic=" + mic +
                ", userInfo=" + userInfo +
                '}';
    }
}
