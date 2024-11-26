// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.http.response;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

import java.util.List;

/**
 * Get the data model returned by the audience list interface
 */
public class GetAudienceListResponse {

    @SerializedName("audience_list")
    public List<LiveUserInfo> audienceList;

    @Override
    public String toString() {
        return "GetAudienceListResponse{" +
                "audienceList=" + audienceList +
                '}';
    }
}
