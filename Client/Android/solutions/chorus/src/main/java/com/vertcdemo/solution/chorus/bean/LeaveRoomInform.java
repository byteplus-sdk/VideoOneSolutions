// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

/**
 * 来自业务服务端离房事件
 */
@RTSInform
public class LeaveRoomInform  {
    @SerializedName("user_info")
    public UserInfo userInfo;
    @SerializedName("audience_count")
    public int audienceCount;
}
