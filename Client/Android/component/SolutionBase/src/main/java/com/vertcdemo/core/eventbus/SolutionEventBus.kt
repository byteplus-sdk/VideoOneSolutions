// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.eventbus

import android.util.Log
import org.greenrobot.eventbus.EventBus

object SolutionEventBus {
    private const val TAG = "SolutionBus"
    private val eventBus = EventBus.getDefault()

    @JvmStatic
    fun post(event: Any) {
        Log.d(TAG, "event=${event.javaClass}")
        eventBus.post(event)
    }

    @JvmStatic
    fun register(subscriber: Any) {
        eventBus.register(subscriber)
    }

    @JvmStatic
    fun unregister(subscriber: Any) {
        eventBus.unregister(subscriber)
    }
}
