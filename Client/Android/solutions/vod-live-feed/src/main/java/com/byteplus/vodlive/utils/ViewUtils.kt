// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.utils

import android.content.Context

object ViewUtils {
    fun dip2Px(context: Context, dipValue: Float): Float {
        val scale: Float = context.resources.displayMetrics.density
        return dipValue * scale + 0.5F
    }
}