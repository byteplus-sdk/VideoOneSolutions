// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.protocol

import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import androidx.core.util.Consumer

interface ILogin {
    fun showLoginView(launcher: ActivityResultLauncher<Intent?>)
    fun closeAccount()
}
