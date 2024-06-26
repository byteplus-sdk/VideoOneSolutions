// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.event.AppTokenExpiredEvent
import com.vertcdemo.core.event.RTSLogoutEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.core.utils.Activities.transparentStatusBar
import com.vertcdemo.login.ILoginImpl
import com.videoone.app.protocol.InitializeManager
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

private const val TAG = "MainActivity"

class MainActivity : AppCompatActivity(), ServiceConnection {
    private val mLogin = ILoginImpl()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        transparentStatusBar(this)

        setContentView(R.layout.activity_main)
        SolutionEventBus.register(this)

        if (savedInstanceState == null) {
            mLogin.showLoginView(loginLauncher)
        }

        // Fix Android 12 Picture In Picture issue.
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.S
            || Build.VERSION.SDK_INT == Build.VERSION_CODES.S_V2) {
            Intent(this, PictureInPictureService::class.java).also { intent ->
                startService(intent)
                bindService(intent, this, Context.BIND_AUTO_CREATE)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        SolutionEventBus.unregister(this)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onTokenExpiredEvent(event: AppTokenExpiredEvent?) {
        mLogin.showLoginView(loginLauncher)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onRTSLogoutEvent(event: RTSLogoutEvent) {
        Log.d(TAG, "onRTSLogoutEvent")
        finishOtherActivity()
        Toast.makeText(this, R.string.same_logged_in, Toast.LENGTH_LONG).show()
        SolutionDataManager.ins().logout()
        SolutionEventBus.post(AppTokenExpiredEvent())
    }

    private fun finishOtherActivity() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
    }

    private val loginLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult())
        { result ->
            if (result.resultCode != RESULT_OK) {
                Log.e(TAG, "login canceled.")
                finish()
            } else {
                InitializeManager.initialize((applicationContext as Application))
            }
        }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        // do nothing
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        // do nothing
    }
}
