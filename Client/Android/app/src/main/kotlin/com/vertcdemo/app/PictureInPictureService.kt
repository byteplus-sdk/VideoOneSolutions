// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

// Fix Android 12 Picture In Picture issue.
class PictureInPictureService : Service() {
    override fun onBind(intent: Intent?): IBinder = PictureInPictureBinder()

    class PictureInPictureBinder : Binder()
}