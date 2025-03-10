// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.ui

import android.view.Gravity
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.MainThread
import androidx.annotation.StringRes
import com.vertcdemo.base.R
import com.vertcdemo.core.utils.AppUtil.applicationContext

@Suppress("DEPRECATION")
object CenteredToast {
    @JvmStatic
    @JvmOverloads
    @MainThread
    fun show(message: String, duration: Int = Toast.LENGTH_SHORT) {
        Toast(applicationContext).apply {
            setGravity(Gravity.CENTER, 0, 0)
            val view =
                LayoutInflater.from(applicationContext)
                    .inflate(R.layout.toast_centered, null) as TextView
            view.text = message
            this.view = view
            this.duration = duration
        }.also {
            it.show()
        }
    }

    @JvmStatic
    @JvmOverloads
    @MainThread
    fun show(@StringRes message: Int, duration: Int = Toast.LENGTH_SHORT) {
        Toast(applicationContext).apply {
            setGravity(Gravity.CENTER, 0, 0)
            val toast =
                LayoutInflater.from(applicationContext)
                    .inflate(R.layout.toast_centered, null) as TextView
            toast.setText(message)
            view = toast
            this.duration = duration
        }.also {
            it.show()
        }
    }
}
