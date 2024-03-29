// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login

import android.content.Context
import android.content.Intent
import android.text.TextUtils
import androidx.activity.result.ActivityResultLauncher
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.core.protocol.ILogin
import com.vertcdemo.core.utils.AppUtil.applicationContext

class ILoginImpl : ILogin {
    override fun showLoginView(launcher: ActivityResultLauncher<Intent?>) {
        val token = SolutionDataManager.ins().token
        if (TextUtils.isEmpty(token)) {
            val context: Context = applicationContext
            launcher.launch(Intent(context, LoginActivity::class.java))
        }
    }

    override fun closeAccount() {
        SolutionDataManager.ins().logout()
        SolutionEventBus.post(AppTokenExpiredEvent())
    }
}
