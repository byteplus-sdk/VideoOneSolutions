// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.model;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

public class UploadResponseModel {
    public static class Body {
        @SerializedName("AccessKeyID")
        public String accessKeyID;

        @SerializedName("SecretAccessKey")
        public String secretAccessKey;

        @SerializedName("SessionToken")
        public String sessionToken;

        @SerializedName("ExpiredTime")
        public String expiredTime;

        @SerializedName("CurrentTime")
        public String currentTime;

        @SerializedName("SpaceName")
        public String spaceName;

        public boolean isInvalid() {
            return TextUtils.isEmpty(this.accessKeyID)
                    || TextUtils.isEmpty(this.secretAccessKey)
                    || TextUtils.isEmpty(this.sessionToken);
        }

        @NonNull
        @Override
        public String toString() {
            return "UploadResponseModel.Body{" +
                    "accessKeyID='" + accessKeyID + '\'' +
                    ", secretAccessKey='" + secretAccessKey + '\'' +
                    ", sessionToken='" + sessionToken + '\'' +
                    ", expiredTime='" + expiredTime + '\'' +
                    ", currentTime='" + currentTime + '\'' +
                    ", spaceName='" + spaceName + '\'' +
                    '}';
        }
    }

    @SerializedName("code")
    public int code;

    @SerializedName("response")
    @Nullable
    public Body body;

    public boolean isSuccess() {
        return code == 200;
    }

    @NonNull
    @Override
    public String toString() {
        return "UploadResponseModel{" +
                "code=" + code +
                ", body=" + body +
                '}';
    }
}
