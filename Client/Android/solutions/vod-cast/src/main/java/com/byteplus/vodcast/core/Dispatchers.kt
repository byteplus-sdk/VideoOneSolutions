// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executor
import java.util.concurrent.Executors

/**
 * Thread dispatch utilities for Cast SDK.
 *
 * Key design:
 * - `castExecutor`: Serial executor for all state writes and protocol operations
 * - `main`: Main thread executor for listener callbacks
 * - All UI-facing callbacks are dispatched through [postMain]
 */
object Dispatchers {

    /** Internal serial executor. All SDK callbacks and state writes go through it. */
    val castExecutor: Executor = Executors.newSingleThreadExecutor { r ->
        Thread(r, "vod-cast-worker").apply { isDaemon = true }
    }

    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    /**
     * Test hook. Null in production; inject "sync execution" implementation in unit tests
     * to avoid RuntimeException("Stub!") from Android Looper/Handler stubs.
     */
    @Volatile
    private var mainOverride: ((() -> Unit) -> Unit)? = null

    /** For unit test use only, pass null to restore production behavior. */
    @JvmStatic
    fun setMainOverrideForTest(override: ((() -> Unit) -> Unit)?) {
        mainOverride = override
    }

    /** Main thread executor. Used for listener dispatch. */
    val main: Executor = Executor { command ->
        val override = mainOverride
        if (override != null) {
            override(command::run)
            return@Executor
        }
        if (Looper.myLooper() == Looper.getMainLooper()) command.run()
        else mainHandler.post(command)
    }

    fun postMain(action: () -> Unit) {
        val override = mainOverride
        if (override != null) {
            override(action)
            return
        }
        if (Looper.myLooper() == Looper.getMainLooper()) action() else mainHandler.post(action)
    }

    fun postCast(action: () -> Unit) {
        castExecutor.execute(action)
    }

    fun assertMainThread(tag: String = "vod-cast") {
        if (mainOverride != null) return
        check(Looper.myLooper() == Looper.getMainLooper()) {
            "$tag must run on main thread, current=${Thread.currentThread().name}"
        }
    }

    fun isMainThread(): Boolean {
        if (mainOverride != null) return true
        return Looper.myLooper() == Looper.getMainLooper()
    }
}
