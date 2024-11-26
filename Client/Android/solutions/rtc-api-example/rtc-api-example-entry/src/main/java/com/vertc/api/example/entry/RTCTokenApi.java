package com.vertc.api.example.entry;

import com.vertc.api.example.entry.bean.GetRTCRoomTokenResult;

import java.util.Map;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface RTCTokenApi {
    @POST("getRTCJoinRoomToken")
    Call<GetRTCRoomTokenResult> getToken(@Body Map<String, Object> body);
}
