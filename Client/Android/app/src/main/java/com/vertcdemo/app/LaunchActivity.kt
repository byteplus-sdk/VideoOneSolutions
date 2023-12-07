// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.vertcdemo.core.utils.Activities.transparentStatusBar
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class LaunchActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        transparentStatusBar(this)
        setContentView(R.layout.activity_launch)
        lifecycleScope.launch {
            delay(1000)
            startActivity(Intent(this@LaunchActivity, MainActivity::class.java))
            finish()
        }
    }
}
