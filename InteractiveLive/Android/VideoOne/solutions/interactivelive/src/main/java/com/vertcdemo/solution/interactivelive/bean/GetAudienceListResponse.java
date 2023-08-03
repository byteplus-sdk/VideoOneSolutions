// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.core.net.rts.RTSResponse;

import java.util.List;

/**
 * Get the data model returned by the audience list interface
 */
@RTSResponse
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
