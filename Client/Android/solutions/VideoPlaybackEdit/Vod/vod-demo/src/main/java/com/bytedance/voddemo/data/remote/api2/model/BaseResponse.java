// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;


import com.google.gson.annotations.SerializedName;

public class BaseResponse {

    @SerializedName("responseMetadata")
    public ResponseMetaData responseMetadata;

    public boolean hasError() {
        return responseMetadata != null && responseMetadata.error != null;
    }

    public ResponseMetaData.ResponseError getError() {
        return responseMetadata == null ? null : responseMetadata.error;
    }

    public static class ResponseMetaData {
        public String requestId;
        public String action;
        public String version;
        public String service;
        public String region;

        @SerializedName("error")
        public ResponseError error;

        public static class ResponseError {
            @SerializedName("code")
            public String code;
            @SerializedName("message")
            public String message;

            @Override
            public String toString() {
                return "ResponseError{" +
                        "code='" + code + '\'' +
                        ", message='" + message + '\'' +
                        '}';
            }
        }
    }
}
