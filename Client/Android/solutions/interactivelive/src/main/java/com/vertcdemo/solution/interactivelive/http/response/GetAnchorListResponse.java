// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

import java.util.Collections;
import java.util.List;

/**
 * Obtain the data model returned by the live broadcast anchor list interface
 */
public class GetAnchorListResponse {

    @SerializedName("anchor_list")
    public List<LiveUserInfo> anchorList;

    @Override
    public String toString() {
        return "GetActiveHostListResponse{" +
                "anchorList=" + anchorList +
                '}';
    }

    @NonNull
    public static List<LiveUserInfo> anchors(@Nullable GetAnchorListResponse response) {
        if (response == null || response.anchorList == null) {
            return Collections.emptyList();
        }

        return response.anchorList;
    }
}
