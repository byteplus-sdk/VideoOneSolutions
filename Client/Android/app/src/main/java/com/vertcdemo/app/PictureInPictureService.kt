package com.vertcdemo.app

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

// Fix Android 12 Picture In Picture issue.
class PictureInPictureService : Service() {
    override fun onBind(intent: Intent?): IBinder? {
        return TestServiceBinder()
    }

    inner class TestServiceBinder : Binder() {
        fun getService() = this@PictureInPictureService
    }
}