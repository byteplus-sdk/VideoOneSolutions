// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.base;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

public class ResponseMeta {
    @SerializedName("requestId")
    public String requestId;
    @SerializedName("action")
    public String action;
    @SerializedName("version")
    public String version;
    @SerializedName("service")
    public String service;
    @SerializedName("region")
    public String region;
    @SerializedName("error")
    public ResponseError error;

    public static class ResponseError {
        public String code;
        public String message;

        @NonNull
        @Override
        public String toString() {
            return "ResponseError{" +
                    "code='" + code + '\'' +
                    ", message='" + message + '\'' +
                    '}';
        }
    }
}
