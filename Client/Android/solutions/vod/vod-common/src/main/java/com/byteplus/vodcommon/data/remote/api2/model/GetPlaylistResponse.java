// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote.api2.model;


import com.google.gson.annotations.SerializedName;

import java.util.List;


public class GetPlaylistResponse extends BaseResponse {
    @SerializedName(value = "response")
    public PlaylistDetail playlistDetail;


    public static class PlaylistDetail {

        @SerializedName(value = "videoList")
        public List<VideoDetail> videoList;

        @SerializedName(value = "playMode")
        public String playMode;
    }
}
