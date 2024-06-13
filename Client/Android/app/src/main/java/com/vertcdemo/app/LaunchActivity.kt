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
        if ((intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT)
            == Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
        ) {
            // Resolve issue:
            //   1. Startup App after install by Installer's OPEN action
            //   2. Launch some page
            //   3. Press HOME button to Launcher
            //   4. Startup App by press AppIcon on Launcher
            //   5. A new LaunchActivity with flag `FLAG_ACTIVITY_BROUGHT_TO_FRONT` will be created
            finish()
            return
        }
        transparentStatusBar(this)
        setContentView(R.layout.activity_launch)
        lifecycleScope.launch {
            delay(1000)
            startActivity(Intent(this@LaunchActivity, MainActivity::class.java))
            finish()
        }
    }
}
