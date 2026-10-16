// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.stream

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.Guideline
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import com.byteplus.live.sport.R
import com.byteplus.live.sport.watch.LiveWatchActivity

class LiveStreamAddressActivity : AppCompatActivity() {

    private lateinit var formBinding: CustomStreamSettingsBinder.Binding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.live_sport_activity_custom_stream)

        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = true

        val statusBarGuide = findViewById<Guideline>(R.id.guideline_status_bar)
        val navBarGuide = findViewById<Guideline>(R.id.guideline_nav_bar)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.root)) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            statusBarGuide.setGuidelineBegin(bars.top)
            navBarGuide.setGuidelineEnd(bars.bottom)
            insets
        }

        findViewById<View>(R.id.btn_back).setOnClickListener { finish() }
        formBinding = CustomStreamSettingsBinder.bind(
            context = this,
            root = findViewById(R.id.custom_stream_form),
            state = CustomStreamSettingsBinder.State(),
        )
        findViewById<TextView>(R.id.btn_watch_now).setOnClickListener {
            val result = formBinding.validate() ?: return@setOnClickListener
            startActivity(
                Intent(this, LiveWatchActivity::class.java).apply {
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_MODE, true)
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_URL, result.streamUrl.url)
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_FORMAT, result.streamUrl.format.name)
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_LOW_LATENCY, result.lowLatencyFlv)
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_SR, result.srOn)
                    putExtra(LiveWatchActivity.EXTRA_CUSTOM_STREAM_SHARPEN, result.sharpenOn)
                }
            )
        }
    }
}
