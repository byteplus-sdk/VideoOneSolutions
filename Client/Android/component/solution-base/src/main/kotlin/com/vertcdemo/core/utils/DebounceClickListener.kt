// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils

import android.os.SystemClock
import android.view.View
import com.vertcdemo.base.R

class DebounceClickListener(
    private val duration: Long = DURATION,
    private val listener: View.OnClickListener
) : View.OnClickListener {

    override fun onClick(v: View) {
        val lastClickTime = v.getTag(R.id.view_click_last_ts) as? Long ?: 0L
        val currentTime = SystemClock.uptimeMillis()

        if (currentTime - lastClickTime < duration) {
            return
        }

        v.setTag(R.id.view_click_last_ts, currentTime)
        listener.onClick(v)
    }

    companion object {
        private const val DURATION = 800L

        @JvmOverloads
        @JvmStatic
        fun create(
            listener: View.OnClickListener,
            duration: Long = DURATION
        ) = DebounceClickListener(duration, listener)
    }
}