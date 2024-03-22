// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

@RTSResponse
public class ReplyResponse {

    @SerializedName("user_info")
    public UserInfo userInfo;

    @NonNull
    @Override
    public String toString() {
        return "ReplyResponse{" +
                "userInfo=" + userInfo +
                '}';
    }
}
