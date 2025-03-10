// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.Event;
import com.vertcdemo.solution.chorus.bean.UserInfo;

public class AudienceChangedEvent {

    public boolean isJoin;
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("audience_count")
    public int audienceCount;

    @Override
    public String toString() {
        return "AudienceChangedEvent{" +
                "userInfo=" + userInfo +
                ", audienceCount=" + audienceCount +
                '}';
    }

    @Event
    public static final class Join extends AudienceChangedEvent {
        public Join() {
            isJoin = true;
        }
    }

    @Event
    public static final class Leave extends AudienceChangedEvent {
        public Leave() {
            isJoin = false;
        }
    }
}