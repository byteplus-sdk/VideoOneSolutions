// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Network availability monitor.
 *
 * Monitors network status and notifies listeners when network transitions occur.
 * Used by ErrorHandler to trigger reconnect after network recovery.
 *
 */
class NetworkMonitor(
    private val context: Context,
) {

    private val listeners = CopyOnWriteArrayList<Listener>()
    private var connectivityManager: ConnectivityManager? = null
    private var callback: ConnectivityManager.NetworkCallback? = null

    @Volatile
    private var hasNetwork = false

    fun start() {
        stop()

        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return

        hasNetwork = checkNetworkAvailable()

        callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                val previous = hasNetwork
                hasNetwork = true
                decideNetworkEvent(previous, hasNetwork)?.let { event ->
                    when (event) {
                        NetworkEvent.RESTORED -> dispatchOnNetworkRestored()
                        NetworkEvent.LOST -> dispatchOnNetworkLost()
                    }
                }
            }

            override fun onLost(network: Network) {
                val previous = hasNetwork
                hasNetwork = false
                decideNetworkEvent(previous, hasNetwork)?.let { event ->
                    when (event) {
                        NetworkEvent.RESTORED -> dispatchOnNetworkRestored()
                        NetworkEvent.LOST -> dispatchOnNetworkLost()
                    }
                }
            }
        }.also {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                connectivityManager?.registerDefaultNetworkCallback(it)
            }
        }
    }

    fun stop() {
        callback?.let {
            connectivityManager?.unregisterNetworkCallback(it)
        }
        callback = null
        connectivityManager = null
    }

    fun hasNetwork(): Boolean = hasNetwork

    fun addListener(listener: Listener) {
        listeners.addIfAbsent(listener)
    }

    fun removeListener(listener: Listener) {
        listeners.remove(listener)
    }

    private fun checkNetworkAvailable(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            connectivityManager?.getNetworkCapabilities(connectivityManager?.activeNetwork)?.let {
                return it.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                        it.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            }
        }
        return connectivityManager?.activeNetworkInfo?.isConnected == true
    }

    private fun dispatchOnNetworkRestored() {
        listeners.forEach { runCatching { it.onNetworkRestored() } }
    }

    private fun dispatchOnNetworkLost() {
        listeners.forEach { runCatching { it.onNetworkLost() } }
    }

    interface Listener {
        /** Main thread. Called when network transitions from unavailable to available. */
        fun onNetworkRestored() {}
        /** Main thread. Called when network transitions from available to unavailable. */
        fun onNetworkLost() {}
    }
}

/** Network event enum for unit testing. */
internal enum class NetworkEvent { RESTORED, LOST }

/**
 * Protocol-agnostic network transition decision.
 *
 * - "no network → has network" → [NetworkEvent.RESTORED]
 * - "has network → no network" → [NetworkEvent.LOST]
 * - otherwise → null
 */
internal fun decideNetworkEvent(previous: Boolean, current: Boolean): NetworkEvent? = when {
    !previous && current -> NetworkEvent.RESTORED
    previous && !current -> NetworkEvent.LOST
    else -> null
}
