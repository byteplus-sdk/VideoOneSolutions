// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.api

import android.net.Uri

/**
 * Protocol-agnostic cast device model.
 */
data class CastDevice(
    val id: String,
    val name: String,
    val description: String? = null,
    val iconUri: Uri? = null,
    val protocol: CastProtocol = CastProtocol.CHROMECAST,
    /** Internal implementation data. Business code should treat this as opaque. */
    val extras: Map<String, Any> = emptyMap(),
)

/** Supported cast protocol types. */
enum class CastProtocol {
    CHROMECAST,
    DLNA,
    AIRPLAY,
}
