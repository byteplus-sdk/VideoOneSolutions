// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.common

import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

object AppExecutors {
    val diskIO: ExecutorService by lazy(LazyThreadSafetyMode.SYNCHRONIZED) { Executors.newSingleThreadExecutor() }
    val networkIO: ExecutorService by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
        Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors())
    }

    val mainHandler: Handler by lazy(LazyThreadSafetyMode.SYNCHRONIZED) { Handler(Looper.getMainLooper()) }

    val mainThread = Executor { mainHandler.post(it) }

    @JvmStatic
    fun diskIO(): ExecutorService = diskIO

    @JvmStatic
    fun mainThread(): Executor = mainThread

    @JvmStatic
    fun networkIO(): ExecutorService = networkIO
}
