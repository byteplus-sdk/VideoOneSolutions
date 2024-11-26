package com.vertcdemo.solution.chorus.http.response;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.chorus.bean.RoomInfo;

import java.util.Collections;
import java.util.List;

public class GetRoomListResponse {
    @SerializedName("room_list")
    public List<RoomInfo> rooms;

    @NonNull
    public static List<RoomInfo> rooms(@Nullable GetRoomListResponse response) {
        if (response == null || response.rooms == null) {
            return Collections.emptyList();
        }
        return response.rooms;
    }
}
