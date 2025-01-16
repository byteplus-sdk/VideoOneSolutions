// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.player

import com.ss.videoarch.liveplayer.VeLivePlayerError
import com.ss.videoarch.liveplayer.VeLivePlayerError.VeLivePlayerErrorCode

fun VeLivePlayerError.string(): String {
    return "code: ${code()}, msg: $mErrorMsg"
}

fun VeLivePlayerError.code(): String = when (this.mErrorCode) {
    VeLivePlayerErrorCode.VeLivePlayerNoError -> "VeLivePlayerNoError"
    VeLivePlayerErrorCode.VeLivePlayerInvalidLicense -> "VeLivePlayerInvalidLicense"
    VeLivePlayerErrorCode.VeLivePlayerInvalidParameter -> "VeLivePlayerInvalidParameter"
    VeLivePlayerErrorCode.VeLivePlayerErrorRefused -> "VeLivePlayerErrorRefused"
    VeLivePlayerErrorCode.VeLivePlayerErrorLibraryLoadFailed -> "VeLivePlayerErrorLibraryLoadFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorPlayUrl -> "VeLivePlayerErrorPlayUrl"
    VeLivePlayerErrorCode.VeLivePlayerErrorNoStreamData -> "VeLivePlayerErrorNoStreamData"
    VeLivePlayerErrorCode.VeLivePlayerErrorInternalRetryStart -> "VeLivePlayerErrorInternalRetryStart"
    VeLivePlayerErrorCode.VeLivePlayerErrorInternalRetryFailed -> "VeLivePlayerErrorInternalRetryFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorDnsParseFailed -> "VeLivePlayerErrorDnsParseFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorNetworkRequestFailed -> "VeLivePlayerErrorNetworkRequestFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorDemuxFailed -> "VeLivePlayerErrorDemuxFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorDecodeFailed -> "VeLivePlayerErrorDecodeFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorAVOutputFailed -> "VeLivePlayerErrorAVOutputFailed"
    VeLivePlayerErrorCode.VeLivePlayerErrorSRDeviceUnsupported -> "VeLivePlayerErrorSRDeviceUnsupported"
    VeLivePlayerErrorCode.VeLivePlayerErrorSRResolutionUnsupported -> "VeLivePlayerErrorSRResolutionUnsupported"
    VeLivePlayerErrorCode.VeLivePlayerErrorSRFpsUnsupported -> "VeLivePlayerErrorSRFpsUnsupported"
    VeLivePlayerErrorCode.VeLivePlayerErrorSRInitFail -> "VeLivePlayerErrorSRInitFail"
    VeLivePlayerErrorCode.VeLivePlayerErrorSRExecuteFail -> "VeLivePlayerErrorSRExecuteFail"
    VeLivePlayerErrorCode.VeLivePlayerLicenseUnsupportedH265 -> "VeLivePlayerLicenseUnsupportedH265"
    VeLivePlayerErrorCode.VeLivePlayerErrorSharpenDeviceUnsupported -> "VeLivePlayerErrorSharpenDeviceUnsupported"
    VeLivePlayerErrorCode.VeLivePlayerErrorInternal -> "VeLivePlayerErrorInternal"
    else -> {
        "${this.mErrorCode}"
    }
}
