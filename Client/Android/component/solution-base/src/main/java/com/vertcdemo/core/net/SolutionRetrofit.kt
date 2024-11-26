// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.net

import android.util.Log
import com.vertcdemo.base.BuildConfig
import com.vertcdemo.core.common.GsonUtils
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory
import java.util.concurrent.TimeUnit

object SolutionRetrofit {
    private const val TAG = "SolutionRetrofit"
    private const val DEBUG = true

    private val retrofit: Retrofit by lazy {
        val httpClient = OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .addInterceptor(EventReturnInterceptor)
            .logging()
            .build()

        val gson = GsonUtils.gson()

        Retrofit.Builder()
            .baseUrl("${BuildConfig.SERVER_URL}/")
            .client(httpClient)
            .addConverterFactory(ScalarsConverterFactory.create())
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
    }

    @JvmStatic
    fun <API> getApi(service: Class<API>): API = retrofit.create(service)

    private fun OkHttpClient.Builder.logging(): OkHttpClient.Builder {
        if (DEBUG) {
            val interceptor = HttpLoggingInterceptor { Log.d(TAG, it) }
            interceptor.level = HttpLoggingInterceptor.Level.BODY
            addInterceptor(interceptor)
        }
        return this
    }
}
