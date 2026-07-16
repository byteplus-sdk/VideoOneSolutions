// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Local player adapter (protocol-agnostic). Implemented by business layer
 * (typically ttvideoengine adapter) and injected via [CastSdk.installLocalPlayerHook].
 *
 * Cast SDK does not directly depend on ttvideoengine / IVideoEngine. All operations
 * requiring "read/write local progress / control local playback" are abstracted here,
 * enabling:
 * - Decoupling casting module from specific player;
 * - Easy mocking in unit tests;
 * - Protocol-agnostic operation for [com.byteplus.vodcast.adapter.CastPlaybackBridge].
 *
 * This hook keeps local playback and remote playback coordinated without coupling the SDK to a specific player.
 */
interface LocalPlayerHook {

    /** Current local playback position in milliseconds. Read it in real time before each cast load. */
    fun currentLocalPositionMs(): Long

    /** Local total duration in milliseconds; returns 0 if unknown. */
    fun currentLocalDurationMs(): Long = 0L

    /** Whether local playback is completed; completed content restarts from the beginning when casting. */
    fun isLocalCompleted(): Boolean = false

    /** Current local playback speed. */
    fun currentLocalSpeed(): Float = 1f

    /**
     * Pause local player when entering casting (CONNECTED). Idempotent.
     * Called only once by Bridge.
     */
    fun pauseLocalPlayback() {}

    /**
     * Write remote [progressMs] back to the local player and resume local playback
     * when exiting casting (DISCONNECTED). This keeps progress in sync and avoids
     * requiring an extra tap to continue playback.
     */
    fun resumeLocalPlayback(progressMs: Long) {}
}
