// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.utils

import android.app.Application

object AppUtil {
    private var mAppCxt: Application? = null

    @JvmStatic
    fun initApp(app: Application?) {
        mAppCxt = app
    }

    @JvmStatic
    val applicationContext: Application
        get() = mAppCxt ?: throw IllegalStateException("Please init app at first!")
}
