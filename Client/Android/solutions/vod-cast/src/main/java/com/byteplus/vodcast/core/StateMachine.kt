// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.CastSessionState.BUFFERING
import com.byteplus.vodcast.api.CastSessionState.CONNECTED
import com.byteplus.vodcast.api.CastSessionState.CONNECTING
import com.byteplus.vodcast.api.CastSessionState.DEVICE_AVAILABLE
import com.byteplus.vodcast.api.CastSessionState.DISCONNECTED
import com.byteplus.vodcast.api.CastSessionState.DISCOVERING
import com.byteplus.vodcast.api.CastSessionState.ENDING
import com.byteplus.vodcast.api.CastSessionState.ERROR
import com.byteplus.vodcast.api.CastSessionState.IDLE
import com.byteplus.vodcast.api.CastSessionState.LOADING
import com.byteplus.vodcast.api.CastSessionState.PAUSED
import com.byteplus.vodcast.api.CastSessionState.PLAYING
import com.byteplus.vodcast.api.CastSessionState.SUSPENDED
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.atomic.AtomicReference

/**
 * Single-writer multi-reader protocol-agnostic state machine.
 *
 * Design goals (spec.md § "State Machine"):
 * - All legal transitions are explicitly enumerated in [TRANSITIONS];
 * - Illegal transitions are dropped by [transitionTo] with WARN log (prevent SDK jitter from messing up UI);
 * - State write operations must happen on castExecutor (guaranteed by [CastController]);
 * - State read callbacks to listeners are dispatched to main thread (determined by caller);
 * - Final IDLE state is explicitly triggered by [CastController] after syncProgressBack.
 *
 * Includes explicit branches for suspension and receiver-side termination states.
 */
class StateMachine(
    initial: CastSessionState = IDLE,
    private val logger: (String) -> Unit = ::println,
) {

    private val ref: AtomicReference<CastSessionState> = AtomicReference(initial)
    private val listeners = CopyOnWriteArrayList<Listener>()

    val state: CastSessionState get() = ref.get()

    /**
     * Try to transition to [next]. Returns true if successful; false if illegal transition is dropped.
     */
    fun transitionTo(next: CastSessionState): Boolean {
        while (true) {
            val current = ref.get()
            if (current == next) return false
            if (!isLegal(current, next)) {
                logger("[StateMachine] illegal transition $current -> $next, dropped")
                return false
            }
            if (ref.compareAndSet(current, next)) {
                listeners.forEach { runCatching { it.onStateChanged(current, next) } }
                return true
            }
            // CAS lost; retry
        }
    }

    /** Force reset (internal SDK use only, e.g. return to IDLE after error recovery). */
    fun resetTo(state: CastSessionState) {
        val prev = ref.getAndSet(state)
        if (prev != state) {
            listeners.forEach { runCatching { it.onStateChanged(prev, state) } }
        }
    }

    fun addListener(listener: Listener) {
        listeners.addIfAbsent(listener)
    }

    fun removeListener(listener: Listener) {
        listeners.remove(listener)
    }

    fun interface Listener {
        fun onStateChanged(from: CastSessionState, to: CastSessionState)
    }

    companion object {
        /**
         * Legal transition set (one-to-one mapping with spec.md mermaid state machine).
         *
         * Note: ERROR and DISCONNECTED are "fallback states", almost all states can transition to them;
         * Determined as a set in [isLegal].
         */
        val TRANSITIONS: Map<CastSessionState, Set<CastSessionState>> = mapOf(
            // CONNECTING is reachable directly from IDLE: device discovery is decoupled
            // from the session state machine, so connect() starts from IDLE.
            IDLE to setOf(DISCOVERING, CONNECTING, ERROR),
            DISCOVERING to setOf(DEVICE_AVAILABLE, CONNECTING, IDLE, ERROR),
            DEVICE_AVAILABLE to setOf(CONNECTING, DISCOVERING, IDLE, ERROR),
            CONNECTING to setOf(CONNECTED, ERROR, DISCONNECTED),
            CONNECTED to setOf(LOADING, SUSPENDED, ENDING, DISCONNECTED, ERROR),
            LOADING to setOf(PLAYING, BUFFERING, ERROR, DISCONNECTED),
            PLAYING to setOf(PAUSED, BUFFERING, ENDING, SUSPENDED, DISCONNECTED, ERROR, LOADING),
            PAUSED to setOf(PLAYING, BUFFERING, ENDING, SUSPENDED, DISCONNECTED, ERROR, LOADING),
            BUFFERING to setOf(PLAYING, PAUSED, ENDING, SUSPENDED, DISCONNECTED, ERROR),
            SUSPENDED to setOf(CONNECTED, DISCONNECTED, ERROR),
            ENDING to setOf(DISCONNECTED, ERROR),
            // CONNECTING is reachable from terminal states so the user can start a new
            // cast right after a session ends (e.g. receiver-ended) or fails.
            DISCONNECTED to setOf(IDLE, DISCOVERING, CONNECTING, ERROR),
            ERROR to setOf(IDLE, DISCONNECTED, CONNECTING),
        )

        fun isLegal(from: CastSessionState, to: CastSessionState): Boolean {
            return TRANSITIONS[from]?.contains(to) == true
        }
    }
}
