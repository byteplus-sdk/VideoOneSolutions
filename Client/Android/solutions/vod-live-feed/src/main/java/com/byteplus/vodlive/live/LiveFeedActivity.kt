// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.byteplus.vodlive.R
import com.vertcdemo.core.utils.fixNavigationBar

const val EXTRA_LIVE_ROOM = "extra_live_room"

class LiveFeedActivity : AppCompatActivity(R.layout.activity_live_feed) {

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        fixNavigationBar()
        super.onCreate(savedInstanceState)
    }
}