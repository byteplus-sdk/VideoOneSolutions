// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic device discovery interface. Lifecycle follows LifecycleOwner
 * (see [CastSdk.addLifecycleObserver]).
 *
 * Related requirements: R-DISCOVERY / R-DISCOVERY-REFRESH.
 */
interface IDiscovery {

    /** Whether currently scanning. */
    val isScanning: Boolean

    /** Current discovered devices snapshot (thread-safe copy). */
    fun currentDevices(): List<CastDevice>

    /** Start scanning; automatically triggered by lifecycle after STARTED,
     * generally no need for manual call. */
    fun start()

    /** Stop scanning; automatically triggered by lifecycle after STOPPED. */
    fun stop()

    /** Force refresh device list (for example after a manual refresh or route changes). */
    fun refresh()

    fun addListener(listener: Listener)
    fun removeListener(listener: Listener)

    interface Listener {
        /** Device list changed (after add/remove/property change). Main thread. */
        fun onDevicesChanged(devices: List<CastDevice>) {}
        /** Single device added. Main thread. */
        fun onDeviceAdded(device: CastDevice) {}
        /** Single device removed. Main thread. */
        fun onDeviceRemoved(device: CastDevice) {}
    }
}
