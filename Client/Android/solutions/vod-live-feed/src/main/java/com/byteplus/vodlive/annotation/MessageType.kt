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