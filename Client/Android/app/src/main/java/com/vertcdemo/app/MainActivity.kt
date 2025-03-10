// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.vertcdemo.core.event.AppLoginEvent
import com.vertcdemo.core.event.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.core.utils.fixNavigationBar
import com.vertcdemo.login.UserViewModel
import com.videoone.app.protocol.InitializeManager
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainActivity : AppCompatActivity(), ServiceConnection {
    private val userViewModel by viewModels<UserViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)

        enableEdgeToEdge()
        fixNavigationBar()

        setContentView(R.layout.activity_main)

        // Fix Android 12 Picture In Picture issue.
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.S
            || Build.VERSION.SDK_INT == Build.VERSION_CODES.S_V2
        ) {
            Intent(this, PictureInPictureService::class.java).also { intent ->
                startService(intent)
                bindService(intent, this, Context.BIND_AUTO_CREATE)
            }
        }

        SolutionEventBus.register(this)
    }

    override fun onDestroy() {
        SolutionEventBus.unregister(this)
        super.onDestroy()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onTokenExpiredEvent(@Suppress("UNUSED_PARAMETER") event: AppTokenExpiredEvent) {
        userViewModel.logout()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onAppLoginEvent(@Suppress("UNUSED_PARAMETER") event: AppLoginEvent) {
        InitializeManager.initialize(application)
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        // do nothing
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        // do nothing
    }
}
