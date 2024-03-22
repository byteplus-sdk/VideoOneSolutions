// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.List;

@RTSResponse
public class GetAudienceResponse {
    @SerializedName("audience_list")
    public List<UserInfo> audienceList;

    @NonNull
    @Override
    public String toString() {
        return "GetAudienceResponse{" +
                "audienceList=" + audienceList +
                '}';
    }
}
