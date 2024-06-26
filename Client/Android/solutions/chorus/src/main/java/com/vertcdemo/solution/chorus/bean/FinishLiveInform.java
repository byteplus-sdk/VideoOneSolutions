// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.bean;

import androidx.annotation.IntDef;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSInform;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * 来自业务服务端结束直播事件
 */
@RTSInform
public class FinishLiveInform {
    public static final int FINISH_TYPE_NORMAL = 1;
    public static final int FINISH_TYPE_TIMEOUT = 2;
    public static final int FINISH_TYPE_AGAINST = 3;

    @IntDef({FINISH_TYPE_NORMAL, FINISH_TYPE_TIMEOUT})
    @Retention(RetentionPolicy.SOURCE)
    public @interface FinishType {
    }

    @SerializedName("room_id")
    public String roomId;
    @SerializedName("type")
    @FinishType
    public int type;
}
