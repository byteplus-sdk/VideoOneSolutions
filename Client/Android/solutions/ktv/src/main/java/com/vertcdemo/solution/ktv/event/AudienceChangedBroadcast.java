// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;
import com.vertcdemo.solution.ktv.bean.UserInfo;

@RTSInform
public class AudienceChangedBroadcast {

    public boolean isJoin;
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("audience_count")
    public int audienceCount;

    @Override
    public String toString() {
        return "AudienceChangedBroadcast{" +
                "userInfo=" + userInfo +
                ", audienceCount=" + audienceCount +
                '}';
    }

    public static class Join extends AudienceChangedBroadcast {
        public Join() {
            isJoin = true;
        }
    }

    public static class Leave extends AudienceChangedBroadcast {
        public Leave() {
            isJoin = false;
        }
    }
}
