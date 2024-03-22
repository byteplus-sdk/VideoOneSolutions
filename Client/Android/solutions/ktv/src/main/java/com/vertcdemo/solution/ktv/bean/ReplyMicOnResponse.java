// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

@RTSResponse
public class ReplyMicOnResponse {

    @SerializedName("is_need_apply")
    public boolean needApply = false;

    @NonNull
    @Override
    public String toString() {
        return "ReplyMicOnRequest{" +
                "needApply=" + needApply +
                '}';
    }
}
