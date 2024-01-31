// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol

import android.app.Application
import android.util.Log

/**
 * @see PlaybackEditInitializer
 */
object InitializeManager {
    private const val TAG = "InitializeManager"

    private val INITIALIZERS = listOf(
        "com.videoone.app.protocol.PlaybackEditInitializer"
    )

    private var called = false

    fun initialize(application: Application) {
        if (called) return
        called = true

        INITIALIZERS.forEach { initializer ->
            invokeInitialize(application, initializer)
        }
    }

    private fun invokeInitialize(application: Application, className: String) {
        try {
            val clazz = Class.forName(className)
            val initializer = clazz.newInstance() as IInitializer
            initializer.initialize(application)
        } catch (e: ReflectiveOperationException) {
            Log.d(TAG, "invokeInitialize: failed", e)
        }
    }
}
