package com.vertc.api.example.entry.bean;

import com.google.gson.annotations.SerializedName;

public class GetRTCRoomTokenResult {
    @SerializedName("Token")
    public String token;
    @SerializedName("ExpiredAt")
    public long expiredAt;
}
