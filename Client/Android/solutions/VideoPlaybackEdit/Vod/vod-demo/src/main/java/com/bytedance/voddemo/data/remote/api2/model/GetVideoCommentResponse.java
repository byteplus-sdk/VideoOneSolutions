// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;


import com.google.gson.annotations.SerializedName;

import java.util.List;


public class GetVideoCommentResponse extends BaseResponse {
    @SerializedName(value = "response")
    public List<CommentDetail> result;
}
