// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.utils

import android.content.Context
import androidx.appcompat.app.AppCompatActivity

object AgreementManager {
    fun <T> check(activity: T) where T : AppCompatActivity, T : ResultCallback =
        activity.onResult(true)

    fun getAgreementStatus(context: Context?): Boolean = true

    interface ResultCallback {
        fun onResult(result: Boolean)
    }
}
