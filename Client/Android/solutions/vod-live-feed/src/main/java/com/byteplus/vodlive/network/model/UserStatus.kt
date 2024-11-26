package com.byteplus.vodlive.network.model

import androidx.annotation.IntDef

@IntDef(
    UserStatus.VOD, UserStatus.LIVE
)
@Retention(AnnotationRetention.SOURCE)
annotation class UserStatus {
    companion object {
        const val VOD: Int = 1
        const val LIVE: Int = 2
    }
}