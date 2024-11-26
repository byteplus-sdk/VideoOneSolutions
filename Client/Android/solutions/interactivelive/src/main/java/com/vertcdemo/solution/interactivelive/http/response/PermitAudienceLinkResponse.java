// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.http.response;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;

import java.util.List;

/**
 * The data model returned by the host replying to the viewer's mic request interface
 */
public class PermitAudienceLinkResponse {

    @SerializedName("rtc_room_id")
    public String rtcRoomId;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("linker_id")
    public String linkerId;
    @SerializedName("rtc_user_list")
    public List<LiveUserInfo> userList;

    @Override
    public String toString() {
        return "PermitAudienceLinkResponse{" +
                "rtcRoomId='" + rtcRoomId + '\'' +
                ", rtcToken='" + rtcToken + '\'' +
                ", linkerId='" + linkerId + '\'' +
                ", userList=" + userList +
                '}';
    }
}
