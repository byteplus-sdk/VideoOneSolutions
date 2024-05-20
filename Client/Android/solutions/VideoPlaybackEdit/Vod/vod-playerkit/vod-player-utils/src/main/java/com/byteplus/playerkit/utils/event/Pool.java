// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils.event;

import android.util.ArrayMap;

import androidx.core.util.Pools;

import java.util.Map;

class Pool {
    private static final Map<Class<? extends Event>, Pools.SimplePool<Event>> sPools = new ArrayMap<>();

    synchronized static <T extends Event> T acquire(Class<T> clazz) {
        Pools.SimplePool<Event> pool = sPools.get(clazz);
        if (pool == null) {
            pool = new Pools.SimplePool<>(Config.EVENT_POOL_SIZE);
            sPools.put(clazz, pool);
        }
        final Event event = pool.acquire();
        if (event != null) {
            return clazz.cast(event);
        }
        return Factory.create(clazz);
    }

    synchronized static void release(Event event) {
        event.recycle();
        final Pools.SimplePool<Event> eventPool = sPools.get(event.getClass());
        if (eventPool != null) {
            eventPool.release(event);
        }
    }
}
