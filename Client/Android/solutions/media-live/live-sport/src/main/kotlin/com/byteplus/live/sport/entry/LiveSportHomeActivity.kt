// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.entry

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.Guideline
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import com.byteplus.live.sport.R
import com.byteplus.live.sport.compare.LiveCompareActivity
import com.byteplus.live.sport.stream.LiveStreamAddressActivity
import com.byteplus.live.sport.watch.LiveWatchActivity

/**
 * Directory page of the Sports Live scenario — three cards leading to:
 *  1. Live Watch (real-time playback with chat / gifts / channel switching)
 *  2. Live Comparison (side-by-side technical comparison)
 *  3. Custom Stream URL (paste-your-own pull URL)
 */
class LiveSportHomeActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Immersive header background extends behind the status bar.
        // `AppTheme.Immersion` alone is NOT enough on target SDK 35 / new OEM ROMs
        // — `enableEdgeToEdge()` is the piece that actually transparentizes the
        // system bars and lets content draw behind them. See AGENTS.md §10.4.
        enableEdgeToEdge()
        setContentView(R.layout.live_sport_activity_home)

        // Light decorative header → dark status bar icons for legibility.
        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = true

        // Push the system-bar height down to the Guideline so the title bar
        // sits below the status bar instead of being clipped.
        val guidelineTop = findViewById<Guideline>(R.id.guideline_top)
        ViewCompat.setOnApplyWindowInsetsListener(window.decorView) { _, insets ->
            guidelineTop.setGuidelineBegin(
                insets.getInsets(WindowInsetsCompat.Type.systemBars()).top
            )
            insets
        }

        // Title bar layout is provided by `live-common`. Project enables
        // `android.nonTransitiveRClass=true`, so cross-module resource ids
        // must be referenced via the fully-qualified R class.
        findViewById<View>(com.byteplus.live.common.R.id.title_bar_left_iv).apply {
            setOnClickListener { finish() }
            // The shared title bar uses marginStart 16dp + padding 13dp, which
            // pushes the arrow's visual edge to ~29dp. Pull marginStart back to
            // 3dp (3 + 13 padding = 16dp) so it lines up with the cards below.
            (layoutParams as ViewGroup.MarginLayoutParams).marginStart =
                (3 * resources.displayMetrics.density + 0.5f).toInt()
        }
        findViewById<TextView>(com.byteplus.live.common.R.id.title_bar_title_tv).apply {
            visibility = View.VISIBLE
            setText(R.string.live_sport_home_title)
        }

        findViewById<View>(R.id.card_watch).setOnClickListener {
            startActivity(Intent(this, LiveWatchActivity::class.java))
        }
        findViewById<View>(R.id.card_compare).setOnClickListener {
            startActivity(Intent(this, LiveCompareActivity::class.java))
        }
        findViewById<View>(R.id.card_input).setOnClickListener {
            startActivity(Intent(this, LiveStreamAddressActivity::class.java))
        }
    }
}
