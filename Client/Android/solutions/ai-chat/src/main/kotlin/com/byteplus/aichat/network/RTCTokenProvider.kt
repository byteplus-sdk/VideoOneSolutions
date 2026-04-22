package com.byteplus.aichat.network

object RTCTokenProvider {
//    private String getRTCJoinRoomToken(String roomId, String userId) throws IOException {
//        HashMap<String, Object> params = new HashMap<>();
//        params.put("room_id", roomId);
//        params.put("user_id", userId);
//        params.put("pub", true);
//        params.put("expire", 1200);// seconds
//        params.put("login_token", SolutionDataManager.ins().getToken());
//
//        if (!TextUtils.isEmpty(APP_KEY)) {
//            params.put("app_key", APP_KEY);
//        }
//        if (!TextUtils.isEmpty(APP_ID)) {
//            params.put("app_id", APP_ID);
//        }
//
//        Response<GetRTCRoomTokenResult> response = SolutionRetrofit.getApi(RTCTokenApi.class)
//            .getToken(params)
//            .execute();
//        GetRTCRoomTokenResult result = response.body();
//        return (result == null ? null : result.token);
//    }

    suspend fun getJoinRoomToken() {

    }
}