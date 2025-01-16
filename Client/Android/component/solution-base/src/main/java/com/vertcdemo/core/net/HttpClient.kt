package com.vertcdemo.core.net

import com.vertcdemo.core.net.SolutionRetrofit.logging
import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit

object HttpClient {
    @JvmStatic
    val client: OkHttpClient by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
        OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .logging()
            .build()
    }
}
