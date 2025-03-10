// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.annotation.Event;


/**
 * User join and leave room events
 */
public abstract class LiveRTSUserEvent {
    @SerializedName("audience_user_id")
    public String audienceUserId;
    @SerializedName("audience_user_name")
    public String audienceUserName;
    @SerializedName("audience_count")
    public int audienceCount;

    public abstract boolean isJoin();

    @Override
    public String toString() {
        return "LiveRTSUserEvent{" +
                "audienceUserId='" + audienceUserId + '\'' +
                ", audienceUserName='" + audienceUserName + '\'' +
                ", audienceCount=" + audienceCount +
                '}';
    }

    @Event
    public static final class Join extends LiveRTSUserEvent {
        public boolean isJoin() {
            return true;
        }
    }

    @Event
    public static final class Leave extends LiveRTSUserEvent {
        public boolean isJoin() {
            return false;
        }
    }
}
