// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import android.content.Context
import androidx.mediarouter.media.MediaControlIntent
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastProtocol
import com.byteplus.vodcast.api.IDiscovery
import com.byteplus.vodcast.core.Dispatchers
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.atomic.AtomicBoolean

/**
 * ChromeCast-backed device discovery implementation.
 *
 * This class exposes a protocol-agnostic [IDiscovery] API, keeps a snapshot of the
 * current route list, supports explicit refresh, and dispatches listener callbacks on
 * the main thread.
 */
internal class ChromecastDiscovery(context: Context) : IDiscovery {

    private val appContext: Context = context.applicationContext
    private val mediaRouter = MediaRouter.getInstance(appContext)

    private val selector: MediaRouteSelector = MediaRouteSelector.Builder()
        .addControlCategory(MediaControlIntent.CATEGORY_REMOTE_PLAYBACK)
        .build()

    private val listeners = CopyOnWriteArrayList<IDiscovery.Listener>()
    private val scanning = AtomicBoolean(false)
    private val devicesRef = CopyOnWriteArrayList<CastDevice>()

    override val isScanning: Boolean get() = scanning.get()

    override fun currentDevices(): List<CastDevice> = devicesRef.toList()

    override fun start() {
        Dispatchers.postMain {
            if (!scanning.compareAndSet(false, true)) {
                rebase(notify = true)
                return@postMain
            }
            mediaRouter.addCallback(
                selector,
                routerCallback,
                MediaRouter.CALLBACK_FLAG_REQUEST_DISCOVERY
            )
            rebase(notify = true)
        }
    }

    override fun stop() {
        Dispatchers.postMain {
            if (!scanning.compareAndSet(true, false)) return@postMain
            mediaRouter.removeCallback(routerCallback)
        }
    }

    override fun refresh() {
        Dispatchers.postMain { rebase(notify = true) }
    }

    override fun addListener(listener: IDiscovery.Listener) {
        listeners.addIfAbsent(listener)
        // Deliver the current snapshot immediately so UI code can render without waiting for route callbacks.
        val snapshot = devicesRef.toList()
        if (snapshot.isNotEmpty()) {
            Dispatchers.postMain { runCatching { listener.onDevicesChanged(snapshot) } }
        }
    }

    override fun removeListener(listener: IDiscovery.Listener) {
        listeners.remove(listener)
    }

/**
     * Returns the currently selected device, if any. Callers must access this on the
     * main thread because it reads directly from MediaRouter state.
     */
    internal fun selectedRoute(): MediaRouter.RouteInfo? {
        val current = mediaRouter.selectedRoute
        return if (current == mediaRouter.defaultRoute || !current.matchesSelector(selector)) {
            null
        } else current
    }

    /** Selects a target route for session establishment. */
    internal fun selectRoute(routeId: String): Boolean {
        val target = mediaRouter.routes.firstOrNull { it.id == routeId } ?: return false
        if (target == mediaRouter.defaultRoute) return false
        if (!target.matchesSelector(selector)) return false
        if (mediaRouter.selectedRoute.id == target.id) return true
        mediaRouter.selectRoute(target)
        return true
    }

    /** Re-selects the default route to leave the current target route. */
    internal fun unselectCurrent() {
        // Selecting the default route effectively leaves the current cast target.
        mediaRouter.selectRoute(mediaRouter.defaultRoute)
    }

    private fun rebase(notify: Boolean) {
        Dispatchers.assertMainThread("ChromecastDiscovery.rebase")
        val routes = mediaRouter.routes
            .filter { it != mediaRouter.defaultRoute && it.matchesSelector(selector) }
        val newList = routes.map { it.toCastDevice() }
        val previousIds = devicesRef.map { it.id }.toSet()
        val newIds = newList.map { it.id }.toSet()

        devicesRef.clear()
        devicesRef.addAll(newList)

        if (!notify) return
        // Full snapshot update
        listeners.forEach { runCatching { it.onDevicesChanged(newList) } }
        // Added devices
        newList.filter { it.id !in previousIds }
            .forEach { added -> listeners.forEach { runCatching { it.onDeviceAdded(added) } } }
        // Removed devices
        previousIds.filter { it !in newIds }
            .forEach { removedId ->
                val placeholder = CastDevice(id = removedId, name = "", protocol = CastProtocol.CHROMECAST)
                listeners.forEach { runCatching { it.onDeviceRemoved(placeholder) } }
            }
    }

    private val routerCallback = object : MediaRouter.Callback() {
        override fun onRouteAdded(router: MediaRouter, route: MediaRouter.RouteInfo) {
            if (route == router.defaultRoute || !route.matchesSelector(selector)) return
            rebase(notify = true)
        }

        override fun onRouteRemoved(router: MediaRouter, route: MediaRouter.RouteInfo) {
            if (route == router.defaultRoute || !route.matchesSelector(selector)) return
            // Rebuild the device snapshot immediately after a route is removed
            rebase(notify = true)
        }

        override fun onRouteChanged(router: MediaRouter, route: MediaRouter.RouteInfo) {
            if (route == router.defaultRoute || !route.matchesSelector(selector)) return
            rebase(notify = true)
        }

        override fun onRouteSelected(
            router: MediaRouter,
            selectedRoute: MediaRouter.RouteInfo,
            reason: Int,
            requestedRoute: MediaRouter.RouteInfo
        ) {
            rebase(notify = true)
        }

        override fun onRouteUnselected(
            router: MediaRouter,
            route: MediaRouter.RouteInfo,
            reason: Int
        ) {
            rebase(notify = true)
        }
    }

    private fun MediaRouter.RouteInfo.toCastDevice(): CastDevice = CastDevice(
        id = id,
        name = name ?: id,
        description = description,
        iconUri = iconUri,
        protocol = CastProtocol.CHROMECAST,
        extras = mapOf("raw" to this),
    )
}
