// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.karaoke;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.vertcdemo.solution.ktv.databinding.ActivityKaraokeScenesBinding;

public class KaraokeScenesActivity extends AppCompatActivity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Window window = getWindow();

        WindowCompat.setDecorFitsSystemWindows(window, false);

        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
        controller.setAppearanceLightStatusBars(true);
        controller.setAppearanceLightNavigationBars(true);

        ActivityKaraokeScenesBinding binding = ActivityKaraokeScenesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        WindowCompat.getInsetsController(window, binding.getRoot())
                .setAppearanceLightStatusBars(true);

        ViewCompat.setOnApplyWindowInsetsListener(binding.guidelineTop, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        PackageManager packageManager = getPackageManager();
        String packageName = getPackageName();

        {
            Intent intent = new Intent(packageName + ".action.KTV_SCENE_SOLO");
            intent.setPackage(packageName);
            ResolveInfo info = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY);

            if (info != null) {
                binding.solo.setOnClickListener(v -> startActivity(intent));
            } else {
                binding.groupSolo.setVisibility(View.GONE);
            }
        }

        {
            Intent intent = new Intent(packageName + ".action.KTV_SCENE_DUET");
            intent.setPackage(packageName);
            ResolveInfo info = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY);

            if (info != null) {
                binding.duet.setOnClickListener(v -> startActivity(intent));
            } else {
                binding.groupDuet.setVisibility(View.GONE);
            }
        }

        binding.back.setOnClickListener(v -> finish());
    }
}
