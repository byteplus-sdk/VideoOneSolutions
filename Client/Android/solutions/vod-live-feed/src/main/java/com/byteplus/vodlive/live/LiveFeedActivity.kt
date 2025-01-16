// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import com.byteplus.vodlive.R

const val EXTRA_LIVE_ROOM = "extra_live_room"

class LiveFeedActivity : AppCompatActivity(R.layout.activity_live_feed) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        WindowCompat.getInsetsController(window, findViewById(android.R.id.content)).apply {
            isAppearanceLightStatusBars = false
            isAppearanceLightNavigationBars = true
        }
    }
}