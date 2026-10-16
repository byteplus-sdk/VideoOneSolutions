// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.adapter

import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.ICastController
import com.byteplus.vodcast.api.IDiscovery
import com.byteplus.vodcast.api.LoadOptions
import com.byteplus.vodcast.api.LocalPlayerHook
import com.byteplus.vodcast.api.MediaItem
import com.byteplus.vodcast.api.RemoteMediaState
import com.byteplus.vodcast.core.Dispatchers
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Covers how [CastPlaybackBridge] coordinates with [LocalPlayerHook] around CONNECTED and DISCONNECTED states.
 */
class CastPlaybackBridgeTest {

    @Before
    fun setUp() {
        Dispatchers.setMainOverrideForTest { it() }
    }

    @After
    fun tearDown() {
        Dispatchers.setMainOverrideForTest(null)
        CastSdk.installLocalPlayerHook(null)
    }

    private class FakeController : ICastController {
        val listeners = CopyOnWriteArrayList<ICastController.Listener>()
        override val state: CastSessionState = CastSessionState.IDLE
        override fun currentRemoteState(): RemoteMediaState = RemoteMediaState.IDLE
        override fun discovery(): IDiscovery = throw UnsupportedOperationException()
        override fun connect(device: CastDevice) {}
        override fun disconnect(endSession: Boolean) {}
        override fun load(item: MediaItem, options: LoadOptions) {}
        override fun switchQuality(item: MediaItem) {}
        override fun play() {}
        override fun pause() {}
        override fun seekTo(positionMs: Long) {}
        override fun setSpeed(speed: Float) {}
        override fun setVolume(volume: Float) {}
        override fun endSession() {}
        override fun addListener(listener: ICastController.Listener) { listeners.add(listener) }
        override fun removeListener(listener: ICastController.Listener) { listeners.remove(listener) }
    }

    private class FakeHook : LocalPlayerHook {
        var pausedCalls = 0
        var resumeCalls = 0
        var lastResumeProgress = -1L
        override fun currentLocalPositionMs(): Long = 0L
        override fun pauseLocalPlayback() { pausedCalls++ }
        override fun resumeLocalPlayback(progressMs: Long) {
            resumeCalls++
            lastResumeProgress = progressMs
        }
    }

    @Test
    fun connected_pauses_local_idempotent_b1() {
        val controller = FakeController()
        val hook = FakeHook()
        CastSdk.installLocalPlayerHook(hook)
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()

        controller.listeners.forEach { it.onStateChanged(CastSessionState.CONNECTED) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.LOADING) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.PLAYING) }

        // Re-entering CONNECTED / LOADING should still pause local playback only once.
        assertEquals(1, hook.pausedCalls)
        assertEquals(0, hook.resumeCalls)
    }

    @Test
    fun disconnected_resumes_local_with_last_progress_b2() {
        val controller = FakeController()
        val hook = FakeHook()
        CastSdk.installLocalPlayerHook(hook)
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()

        controller.listeners.forEach { it.onStateChanged(CastSessionState.CONNECTED) }
        controller.listeners.forEach { it.onProgressChanged(12_345L, 60_000L) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.DISCONNECTED) }

        assertEquals(1, hook.pausedCalls)
        assertEquals(1, hook.resumeCalls)
        assertEquals(12_345L, hook.lastResumeProgress)
    }

    @Test
    fun resume_only_when_previously_paused_no_double_resume() {
        val controller = FakeController()
        val hook = FakeHook()
        CastSdk.installLocalPlayerHook(hook)
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()

        // A direct DISCONNECTED state should not trigger resume when local playback was never paused.
        controller.listeners.forEach { it.onStateChanged(CastSessionState.DISCONNECTED) }
        assertEquals(0, hook.pausedCalls)
        assertEquals(0, hook.resumeCalls)
    }

    @Test
    fun progress_clears_after_disconnect_to_avoid_b2_pollution() {
        val controller = FakeController()
        val hook = FakeHook()
        CastSdk.installLocalPlayerHook(hook)
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()

        // First session
        controller.listeners.forEach { it.onStateChanged(CastSessionState.CONNECTED) }
        controller.listeners.forEach { it.onProgressChanged(50_000L, 60_000L) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.DISCONNECTED) }
        assertEquals(50_000L, hook.lastResumeProgress)

        // Second session; without clearing cached progress, DISCONNECTED would reuse the previous 50_000 ms value.
        controller.listeners.forEach { it.onStateChanged(CastSessionState.CONNECTED) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.DISCONNECTED) }
        assertEquals("Without a new progress callback, the second session should resume from 0", 0L, hook.lastResumeProgress)
    }

    @Test
    fun detach_unregisters_listener() {
        val controller = FakeController()
        val hook = FakeHook()
        CastSdk.installLocalPlayerHook(hook)
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()
        bridge.detach()
        assertTrue(controller.listeners.isEmpty())

        // Repeated attach / detach calls should remain idempotent.
        bridge.detach()
        bridge.attach()
        bridge.attach()
        assertEquals(1, controller.listeners.size)
    }

    @Test
    fun no_hook_installed_does_not_crash() {
        CastSdk.installLocalPlayerHook(null)
        val controller = FakeController()
        val bridge = CastPlaybackBridge(controller)
        bridge.attach()
        // No exception should be thrown when no hook is installed.
        controller.listeners.forEach { it.onStateChanged(CastSessionState.CONNECTED) }
        controller.listeners.forEach { it.onStateChanged(CastSessionState.DISCONNECTED) }
        assertNull(CastSdk.localPlayerHook())
        assertFalse(controller.listeners.isEmpty())
    }
}
