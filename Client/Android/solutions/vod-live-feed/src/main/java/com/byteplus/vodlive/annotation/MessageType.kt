// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.annotation

import androidx.annotation.IntDef


@IntDef(
    MessageType.MSG, MessageType.GIFT, MessageType.LIKE
)
@Retention(AnnotationRetention.SOURCE)
annotation class MessageType {
    companion object {
        const val MSG: Int = 1
        const val GIFT: Int = 2
        const val LIKE: Int = 3
    }
}
