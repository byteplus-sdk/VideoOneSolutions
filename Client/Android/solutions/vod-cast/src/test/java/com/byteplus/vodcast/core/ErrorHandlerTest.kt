// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastOptions
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

/**
 * Covers the recovery strategies for the supported [CastErrorCode] cases in [ErrorHandler].
 */
class ErrorHandlerTest {

    /** Runs Dispatchers.postMain synchronously in tests to avoid a Handler stub. */
    @Before
    fun setUp() {
        Dispatchers.setMainOverrideForTest { it() }
    }

    @After
    fun tearDown() {
        Dispatchers.setMainOverrideForTest(null)
    }

    private class FakeHooks(val mediaLoadCanRetry: Boolean = true) : ErrorHandler.Hooks {
        var emitted: CastError? = null
        var toasted: CastError? = null
        var retryCalls = 0
        var reconnectCalls = 0
        var forceDisconnectCalls = 0

        /** Executes scheduled actions immediately in tests to avoid timer-based behavior. */
        var executeDelayedImmediately = true
        val pendingActions = mutableListOf<() -> Unit>()
        var lastDelayMs: Long = -1L
        val cancelledTokens = mutableListOf<Long>()

        override fun emit(error: CastError) { emitted = error }
        override fun showToast(error: CastError) { toasted = error }
        override fun retryMediaLoad(): Boolean { retryCalls++; return mediaLoadCanRetry }
        override fun tryReconnect() { reconnectCalls++ }
        override fun forceDisconnect() { forceDisconnectCalls++ }

        override fun scheduleDelayed(delayMs: Long, action: () -> Unit): ErrorHandler.Cancellable {
            lastDelayMs = delayMs
            return if (executeDelayedImmediately) {
                action()
                object : ErrorHandler.Cancellable {
                    override fun cancel() {
                        cancelledTokens.add(delayMs)
                    }
                }
            } else {
                pendingActions.add(action)
                val idx = pendingActions.size - 1
                object : ErrorHandler.Cancellable {
                    override fun cancel() {
                        cancelledTokens.add(delayMs)
                        if (idx in pendingActions.indices) pendingActions[idx] = {}
                    }
                }
            }
        }
    }

    private fun newHandler(
        hooks: FakeHooks = FakeHooks(),
        options: CastOptions = CastOptions.default(),
    ): Pair<ErrorHandler, FakeHooks> = ErrorHandler(hooks, options) to hooks

    @Test
    fun media_load_failed_triggers_retry_once() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED))
        // With the default mediaLoadRetry = 1, the first retry should run and the second should not.
        h.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED))
        assertEquals(1, hooks.retryCalls)
        assertNotNull(hooks.emitted)
    }

    @Test
    fun media_load_failed_resets_after_session_reset() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED))
        assertEquals(1, hooks.retryCalls)
        h.onSessionReset()
        h.handle(CastError(CastErrorCode.MEDIA_LOAD_FAILED))
        assertEquals(2, hooks.retryCalls)
    }

    @Test
    fun suspended_schedules_force_disconnect_b3() {
        val hooks = FakeHooks()
        hooks.executeDelayedImmediately = true
        val (h, _) = newHandler(hooks, CastOptions.default().copy(suspendedTimeoutMs = 30_000L))
        h.handle(CastError(CastErrorCode.SESSION_SUSPENDED))
        assertEquals(30_000L, hooks.lastDelayMs)
        assertEquals(1, hooks.forceDisconnectCalls)
    }

    @Test
    fun suspended_resumed_cancels_force_disconnect_b3() {
        val hooks = FakeHooks()
        hooks.executeDelayedImmediately = false
        val (h, _) = newHandler(hooks)
        h.handle(CastError(CastErrorCode.SESSION_SUSPENDED))
        h.onSessionResumed()
        // After cancellation, even if we run the pending action manually it should not trigger forceDisconnect again.
        hooks.pendingActions.forEach { it() }
        assertEquals(0, hooks.forceDisconnectCalls)
        assertTrue(hooks.cancelledTokens.isNotEmpty())
    }

    @Test
    fun network_lost_does_not_immediately_reconnect_b8() {
        val hooks = FakeHooks()
        hooks.executeDelayedImmediately = false
        val (h, _) = newHandler(hooks)
        h.handle(CastError(CastErrorCode.NETWORK_LOST))
        assertEquals(0, hooks.reconnectCalls)
    }

    @Test
    fun network_restored_triggers_reconnect_b8() {
        val (h, hooks) = newHandler()
        h.onNetworkRestored()
        assertEquals(1, hooks.reconnectCalls)
    }

    @Test
    fun taken_over_toasts_and_emits_b4() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.SESSION_TAKEN_OVER))
        assertNotNull(hooks.toasted)
        assertEquals(CastErrorCode.SESSION_TAKEN_OVER, hooks.toasted!!.code)
        assertNotNull(hooks.emitted)
        assertEquals(0, hooks.retryCalls)
    }

    @Test
    fun ended_by_receiver_toasts_and_emits_b5() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.SESSION_ENDED_BY_RECEIVER))
        assertNotNull(hooks.toasted)
        assertEquals(CastErrorCode.SESSION_ENDED_BY_RECEIVER, hooks.toasted!!.code)
    }

    @Test
    fun no_network_toasts_and_emits_b9() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.NO_NETWORK))
        assertNotNull(hooks.toasted)
        assertEquals(CastErrorCode.NO_NETWORK, hooks.toasted!!.code)
    }

    @Test
    fun device_unavailable_only_emits() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.DEVICE_UNAVAILABLE))
        assertNotNull(hooks.emitted)
        assertNull(hooks.toasted)
    }

    @Test
    fun session_start_failed_only_emits() {
        val (h, hooks) = newHandler()
        h.handle(CastError(CastErrorCode.SESSION_START_FAILED))
        assertNotNull(hooks.emitted)
        assertNull(hooks.toasted)
        assertEquals(0, hooks.retryCalls)
    }

    @Test
    fun cast_error_recoverable_default_matches_spec() {
        // 5 recoverable cases
        listOf(
            CastErrorCode.SESSION_START_FAILED,
            CastErrorCode.SESSION_SUSPENDED,
            CastErrorCode.MEDIA_LOAD_FAILED,
            CastErrorCode.NETWORK_LOST,
            CastErrorCode.NO_NETWORK,
        ).forEach { assertTrue("$it should be recoverable", CastError(it).recoverable) }

        // 3 non-recoverable cases
        listOf(
            CastErrorCode.SESSION_TAKEN_OVER,
            CastErrorCode.SESSION_ENDED_BY_RECEIVER,
            CastErrorCode.DEVICE_UNAVAILABLE,
        ).forEach { assertFalse("$it should be non-recoverable", CastError(it).recoverable) }
    }
}
