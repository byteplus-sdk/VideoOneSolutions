// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertc.api.example.entry.bean;

import com.google.gson.annotations.SerializedName;

public class GetRTCRoomTokenResult {
    @SerializedName("Token")
    public String token;
    @SerializedName("ExpiredAt")
    public long expiredAt;
}
