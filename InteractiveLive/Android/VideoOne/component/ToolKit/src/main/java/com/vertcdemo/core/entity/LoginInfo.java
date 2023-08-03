// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.entity;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

public class LoginInfo {
    @SerializedName("user_id")
    public String userId;
    @SerializedName("user_name")
    public String userName;
    @SerializedName("login_token")
    public String loginToken;

    @NonNull
    @Override
    public String toString() {
        return "LoginInfo{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", loginToken='" + loginToken + '\'' +
                '}';
    }
}
