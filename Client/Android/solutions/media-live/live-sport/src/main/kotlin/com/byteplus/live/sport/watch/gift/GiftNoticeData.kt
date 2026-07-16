// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.gift

import androidx.annotation.DrawableRes

/** Data for one transient "gift sent" notice shown above the portrait chat. */
data class GiftNoticeData(
    @DrawableRes val avatarRes: Int,
    val senderName: String,
    val giftName: String,
    @DrawableRes val giftIconRes: Int,
    val count: Int = 1,
)
