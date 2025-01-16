// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.byteplus.vod.minidrama.remote.model.base.ResponseMeta;
import com.google.gson.annotations.SerializedName;

public class ServerReturnResponse<T> {
    @SerializedName("request_id")
    public String requestId;

    @SerializedName("code")
    public int code;
    @SerializedName("message")
    public String message;

    @SerializedName("timestamp")
    public long timestamp;

    @SerializedName("response")
    public T response;

    @SerializedName("responseMetadata")
    public ResponseMeta responseMetadata;

    public boolean isSuccessful() {
        return code == 200;
    }
}
