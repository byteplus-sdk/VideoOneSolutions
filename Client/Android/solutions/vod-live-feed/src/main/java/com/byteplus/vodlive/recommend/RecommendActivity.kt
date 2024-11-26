package com.byteplus.vodlive.recommend

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import com.byteplus.voddemo.utils.OuterActionsHelper
import com.byteplus.vodlive.R

class RecommendActivity : AppCompatActivity(R.layout.activity_recommend) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowCompat.getInsetsController(window, findViewById(android.R.id.content)).apply {
            isAppearanceLightStatusBars = false
            isAppearanceLightNavigationBars = true
        }

        OuterActionsHelper.setup()
    }
}