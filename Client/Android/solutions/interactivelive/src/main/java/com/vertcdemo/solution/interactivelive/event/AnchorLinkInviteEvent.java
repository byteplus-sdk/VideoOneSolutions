// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

/**
 * anchor connection invitation event
 */
public class AnchorLinkInviteEvent {
    @SerializedName("inviter")
    public LiveUserInfo userInfo;
    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("extra")
    public String extra;

    @NonNull
    @Override
    public String toString() {
        return "AudienceLinkInviteEvent{" +
                "userInfo=" + userInfo +
                ", linkerId='" + linkerId + '\'' +
                ", extra='" + extra + '\'' +
                '}';
    }
}
