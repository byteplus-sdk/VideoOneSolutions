// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.avatars

import androidx.annotation.DrawableRes

object Avatars {
    val avatars = intArrayOf(
        R.drawable.avatar00,
        R.drawable.avatar01,
        R.drawable.avatar02,
        R.drawable.avatar03,
        R.drawable.avatar04,
        R.drawable.avatar05,
        R.drawable.avatar06,
        R.drawable.avatar07,
        R.drawable.avatar08,
        R.drawable.avatar09,
        R.drawable.avatar10,
        R.drawable.avatar11,
        R.drawable.avatar12,
        R.drawable.avatar13,
        R.drawable.avatar14,
        R.drawable.avatar15,
        R.drawable.avatar16,
        R.drawable.avatar17,
        R.drawable.avatar18,
        R.drawable.avatar19,
    )

    @JvmStatic
    @DrawableRes
    fun byUserId(id: String?): Int {
        return if (id == null) {
            R.drawable.avatar00
        } else try {
            val num = id.toLong()
            avatars[(num % avatars.size).toInt()]
        } catch (e: Exception) {
            R.drawable.avatar00
        }
    }
}