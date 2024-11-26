package com.byteplus.vodlive.network

import com.byteplus.vodlive.network.model.GetFeedWithLiveRequest
import com.byteplus.vodlive.network.model.GetLiveOnlyRequest
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.network.model.MixFeedItem
import com.byteplus.vodlive.network.model.SendMessageRequest
import com.byteplus.vodlive.network.model.SwitchLiveRoomRequest
import com.byteplus.vodlive.network.model.SwitchLiveRoomResult
import com.vertcdemo.core.net.SolutionRetrofit
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST

const val VOD_PAGE_SIZE = 10

interface VodLiveApi {
    @POST("liveFeed/v1/getFeedStreamWithLive")
    suspend fun getFeedWithLive(@Body request: GetFeedWithLiveRequest): Response<List<MixFeedItem>?>

    @POST("liveFeed/v1/getFeedStreamOnlyLive")
    suspend fun getFeedOnlyLive(@Body request: GetLiveOnlyRequest): Response<List<LiveFeedItem>?>

    @POST("liveFeed/v1/switchFeedLiveRoom")
    suspend fun switchLiveRoom(@Body request: SwitchLiveRoomRequest): SwitchLiveRoomResult

    @POST("liveFeed/v1/liveSendMessage")
    suspend fun sendMessage(@Body request: SendMessageRequest): Response<Any>
}

val vodLiveApi: VodLiveApi
    get() = SolutionRetrofit.getApi(VodLiveApi::class.java)