// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.bean.UserInfo;

import java.util.Collections;
import java.util.List;

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

    @NonNull
    public static List<UserInfo> audiences(@Nullable GetAudienceResponse response) {
        if (response == null || response.audienceList == null) {
            return Collections.emptyList();
        }
        return response.audienceList;
    }
}
