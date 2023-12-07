// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;


import com.google.gson.annotations.SerializedName;

public class BaseResponse {
    @SerializedName("code")
    public int code;

    @SerializedName("message")
    public String message;

    public boolean hasError() {
        return code != 200;
    }

    public String getError() {
        return code + "/" + message;
    }
}
