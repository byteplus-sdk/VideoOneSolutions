// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic casting session state.
 *
 * State machine transitions refer to spec.md § "State Machine (mermaid)":
 *   IDLE → DISCOVERING → DEVICE_AVAILABLE → CONNECTING → CONNECTED
 *        → LOADING → PLAYING / PAUSED / BUFFERING
 *        → ENDING → DISCONNECTED → IDLE
 *   Horizontal: CONNECTED ↔ SUSPENDED; Any → ERROR.
 *
 * Optional integer mapping used by integrations that consume a compact session state.
 */
enum class CastSessionState {
    IDLE,
    DISCOVERING,
    DEVICE_AVAILABLE,
    CONNECTING,
    CONNECTED,
    LOADING,
    PLAYING,
    PAUSED,
    BUFFERING,
    SUSPENDED,
    ENDING,
    DISCONNECTED,
    ERROR;

    /** Whether UI should show casting mode (e.g. CastingModeLayer). */
    val isCasting: Boolean
        get() = when (this) {
            CONNECTED, LOADING, PLAYING, PAUSED, BUFFERING, SUSPENDED, ENDING -> true
            else -> false
        }

    /** Whether progress callbacks are enabled. */
    val canEmitProgress: Boolean
        get() = this == PLAYING || this == PAUSED || this == BUFFERING

    /** Returns a compact integer form: disconnected=0, connecting=1, connected/casting=2. */
    fun toLegacyInt(): Int = when (this) {
        IDLE, DISCONNECTED, ERROR -> 0
        DISCOVERING, DEVICE_AVAILABLE, CONNECTING -> 1
        else -> 2
    }
}
