// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

/**
 * Protocol-agnostic error codes. Covers all 8 types from spec.md § "Error Codes / Retry Strategy".
 */
enum class CastErrorCode {
    /** Connection failed. Failed or timeout (10s) during CONNECTING phase. recoverable */
    SESSION_START_FAILED,

    /** Receiver temporarily offline. Falls back to DISCONNECTED if not recovered within 30s. recoverable */
    SESSION_SUSPENDED,

    /** Receiver taken over by another sender. non-recoverable */
    SESSION_TAKEN_OVER,

    /** Receiver actively ended casting. non-recoverable */
    SESSION_ENDED_BY_RECEIVER,

    /** Remote load failed. recoverable, auto-retry once. */
    MEDIA_LOAD_FAILED,

    /** Network lost. recoverable, reconnect within 10s after recovery. */
    NETWORK_LOST,

    /** No network when clicking the cast entry. recoverable, UI toast. */
    NO_NETWORK,

    /** Device permanently unavailable. non-recoverable. */
    DEVICE_UNAVAILABLE,
}

/**
 * Protocol-agnostic error object.
 *
 * @property code     Error code
 * @property reason   Platform original error message (nullable)
 * @property recoverable Whether business should attempt recovery
 * @property cause    Underlying exception
 */
data class CastError(
    val code: CastErrorCode,
    val reason: String? = null,
    val recoverable: Boolean = code.defaultRecoverable(),
    val cause: Throwable? = null,
) {
    override fun toString(): String =
        "CastError(code=$code, recoverable=$recoverable, reason=$reason, cause=$cause)"
}

private fun CastErrorCode.defaultRecoverable(): Boolean = when (this) {
    CastErrorCode.SESSION_START_FAILED,
    CastErrorCode.SESSION_SUSPENDED,
    CastErrorCode.MEDIA_LOAD_FAILED,
    CastErrorCode.NETWORK_LOST,
    CastErrorCode.NO_NETWORK -> true

    CastErrorCode.SESSION_TAKEN_OVER,
    CastErrorCode.SESSION_ENDED_BY_RECEIVER,
    CastErrorCode.DEVICE_UNAVAILABLE -> false
}
