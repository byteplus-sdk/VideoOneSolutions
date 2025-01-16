// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class DramaUnlockMeta implements Serializable {
    @SerializedName("drama_id")
    public String dramaId;
    @SerializedName("vid")
    public String vid;
    @SerializedName("order")
    public int episodeNumber;
    @SerializedName("play_auth_token")
    public String playAuthToken;
    @SerializedName("subtitle_auth_token")
    public String subtitleAuthToken;
}
