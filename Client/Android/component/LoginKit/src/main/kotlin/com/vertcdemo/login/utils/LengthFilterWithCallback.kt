// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.utils

import android.text.InputFilter
import android.text.Spanned
import android.text.TextUtils

class LengthFilterWithCallback(
    private val mMax: Int,
    private val mOverflowCallback: OverflowCallback
) : InputFilter {
    override fun filter(
        source: CharSequence, start: Int, end: Int, dest: Spanned,
        dstart: Int, dend: Int
    ): CharSequence? {
        if (TextUtils.isEmpty(source)) {
            mOverflowCallback.isOverflow(false)
            return ""
        }
        var keep = mMax - (dest.length - (dend - dstart))
        return if (keep <= 0) {
            mOverflowCallback.isOverflow(true)
            ""
        } else if (keep >= end - start) {
            mOverflowCallback.isOverflow(false)
            return null // keep original
        } else {
            keep += start
            if (Character.isHighSurrogate(source[keep - 1])) {
                --keep
                if (keep == start) {
                    mOverflowCallback.isOverflow(true)
                    return ""
                }
            }
            mOverflowCallback.isOverflow(true)
            return source.subSequence(start, keep)
        }
    }

    fun interface OverflowCallback {
        fun isOverflow(overflow: Boolean)
    }
}
