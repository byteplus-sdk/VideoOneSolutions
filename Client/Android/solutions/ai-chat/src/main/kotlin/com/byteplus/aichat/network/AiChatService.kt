package com.byteplus.aichat.network

import com.byteplus.aichat.bean.AiConfigResponse
import com.byteplus.aichat.bean.GetRTCRoomTokenResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface AiChatService {
    @GET("aigc/v1/getAIConfig")
    suspend fun getAiConfig(@Query("lang") lang: String): AiConfigResponse?

    @POST("getRTCJoinRoomToken")
    suspend fun getRTCRoomToken(@Body params: Map<String, @JvmSuppressWildcards Any>): GetRTCRoomTokenResponse?

    @POST("aigc/v1/startRealTimeVoiceChat")
    suspend fun startRealTimeVoiceChat(@Body params: Map<String, @JvmSuppressWildcards Any>): Response<Any>

    @POST("aigc/v1/stopRealTimeVoiceChat")
    suspend fun stopRealTimeVoiceChat(@Body params: Map<String, @JvmSuppressWildcards Any>): Response<Any>

    @POST("aigc/v1/startFlexibleVoiceChat")
    suspend fun startFlexibleVoiceChat(@Body params: Map<String, @JvmSuppressWildcards Any>): Response<Any>

    @POST("aigc/v1/stopFlexibleVoiceChat")
    suspend fun stopFlexibleVoiceChat(@Body params: Map<String, @JvmSuppressWildcards Any>): Response<Any>

}