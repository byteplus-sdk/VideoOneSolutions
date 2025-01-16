// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.room

import android.util.Log
import org.greenrobot.eventbus.EventBus

object RoomEventBus {
    private const val TAG = "RoomEventBus"

    private val eventBus = EventBus
        .builder()
        .build()

    fun register(obj: Any) {
        Log.d(TAG, "register +=${obj.javaClass}")
        eventBus.register(obj)
    }

    fun unregister(obj: Any) {
        Log.d(TAG, "unregister -=${obj.javaClass}")
        eventBus.unregister(obj)
    }

    fun post(event: Any) {
        Log.d(TAG, "event=${event.javaClass}")
        eventBus.post(event)
    }
}