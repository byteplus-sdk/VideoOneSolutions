// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.network.model

import androidx.annotation.IntDef

@IntDef(
    FeedType.VOD, FeedType.LIVE
)
@Retention(AnnotationRetention.SOURCE)
annotation class FeedType {
    companion object {
        const val VOD: Int = 1
        const val LIVE: Int = 2
    }
}