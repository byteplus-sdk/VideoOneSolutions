// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.karaoke;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.vertcdemo.solution.chorus.feature.ChorusEntryActivity;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.databinding.ActivityKaraokeScenesBinding;
import com.vertcdemo.solution.ktv.feature.KTVEntryActivity;

public class KaraokeScenesActivity extends AppCompatActivity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Window window = getWindow();

        WindowCompat.setDecorFitsSystemWindows(window, false);

        // for HONOR 50, HTH-AN00, MagicOS 7, Android 12
        // This device need this line to set status bar TRANSPARENT and should called before setStatusBarColor
        window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);

        window.setStatusBarColor(Color.TRANSPARENT);
        window.setNavigationBarColor(Color.TRANSPARENT);

        ActivityKaraokeScenesBinding binding = ActivityKaraokeScenesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        WindowCompat.getInsetsController(window, binding.getRoot())
                .setAppearanceLightStatusBars(true);

        ViewCompat.setOnApplyWindowInsetsListener(binding.guidelineTop, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.solo.setOnClickListener(v -> {
            Intent intent = new Intent(this, KTVEntryActivity.class);
            startActivity(intent);
        });

        binding.duet.setOnClickListener(v -> {
            Intent intent = new Intent(this, ChorusEntryActivity.class);
            startActivity(intent);
        });

        binding.back.setOnClickListener(v -> finish());
    }
}
