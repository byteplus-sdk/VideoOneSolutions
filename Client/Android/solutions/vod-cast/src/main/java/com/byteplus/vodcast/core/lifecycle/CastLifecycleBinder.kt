// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core.lifecycle

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.byteplus.vodcast.api.CastSdk

/**
 * Lifecycle bridge for [CastSdk].
 *
 * - `onStart` starts device discovery.
 * - `onStop` stops device discovery to avoid unnecessary background work.
 * - `onDestroy` removes this observer to avoid leaking the lifecycle owner.
 *
 * Calls are guarded with `runCatching`, so attaching the observer before the cast
 * implementation is fully registered remains safe.
 */
internal class CastLifecycleBinder(
    private val sdk: CastSdk,
) : DefaultLifecycleObserver {

    override fun onStart(owner: LifecycleOwner) {
        runCatching { sdk.discovery().start() }
    }

    override fun onStop(owner: LifecycleOwner) {
        runCatching { sdk.discovery().stop() }
    }

    override fun onDestroy(owner: LifecycleOwner) {
        // Remove the observer itself; business listeners are managed separately.
        owner.lifecycle.removeObserver(this)
    }
}
