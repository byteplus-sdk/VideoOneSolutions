// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

/**
 * audience apply for connection events
 */
@RTSInform
public class AudienceLinkInviteEvent {

    @SerializedName("inviter")
    public LiveUserInfo userInfo;
    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("extra")
    public String extra;

    @Override
    public String toString() {
        return "AudienceLinkInviteEvent{" +
                "userInfo=" + userInfo +
                ", linkerId='" + linkerId + '\'' +
                ", extra='" + extra + '\'' +
                '}';
    }
}
