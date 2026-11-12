// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.settings;


import androidx.fragment.app.Fragment;
import android.os.Bundle;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.utils.L;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import androidx.appcompat.widget.SwitchCompat;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Toast;


public class DramaSettingsFragment extends Fragment {
    
    public DramaSettingsFragment() {
        super(R.layout.vevod_mini_drama_settings_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        bindHomeSettings(view);

        SwitchCompat prerollSwitch = getView().findViewById(R.id.prerollSwitch);
        if (prerollSwitch != null) {
            prerollSwitch.setChecked(DramaSettings.isPrerollAdEnabled());
            prerollSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    L.d(this, "preroll set: ", isChecked);
                    DramaSettings.enablePrerollAd(isChecked);
                }
            });
        }

        SwitchCompat midrollSwitch = getView().findViewById(R.id.midrollSwitch);
        if (midrollSwitch != null) {
            midrollSwitch.setChecked(DramaSettings.isMidrollAdEnabled());
            midrollSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    L.d(this, "midrollSwitch set: ", isChecked);
                    DramaSettings.enableMidrollAd(isChecked);
                }
            });
        }

        SwitchCompat postrollSwitch = getView().findViewById(R.id.postrollSwitch);
        if (postrollSwitch != null) {
            postrollSwitch.setChecked(DramaSettings.isPostrollAdEnabled());
            postrollSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    L.d(this, "postrollSwitch set: ", isChecked);
                    DramaSettings.enablePostrollAd(isChecked);
                }
            });
        }
    }

    private void bindHomeSettings(View view) {
        DramaSettings.initializeHomeSettings(requireContext());
        HomePreloadOverrides values = DramaSettings.getHomePreloadOverrides();
        SwitchCompat override = view.findViewById(R.id.homePreloadOverride);
        SwitchCompat downloads = view.findViewById(R.id.homePreloadDownloads);
        SwitchCompat warmup = view.findViewById(R.id.homePreloadWarmup);
        SwitchCompat enhanced = view.findViewById(R.id.homePreloadEnhancedWindow);
        EditText speed = view.findViewById(R.id.homePreloadSpeed);
        EditText interval = view.findViewById(R.id.homePreloadInterval);
        override.setChecked(values.enabled);
        downloads.setChecked(values.downloads);
        warmup.setChecked(values.startupWarmup);
        enhanced.setChecked(values.enhancedWindowEnabled);
        speed.setText(String.valueOf(values.speedDpPerSecond));
        interval.setText(String.valueOf(values.updateIntervalMs));
        Runnable enableFields = () -> {
            boolean enabled = override.isChecked();
            downloads.setEnabled(enabled);
            warmup.setEnabled(enabled);
            enhanced.setEnabled(enabled && downloads.isChecked());
            boolean moving = enabled && downloads.isChecked() && enhanced.isChecked();
            speed.setEnabled(moving);
            interval.setEnabled(moving);
        };
        enableFields.run();
        override.setOnCheckedChangeListener((button, checked) -> enableFields.run());
        downloads.setOnCheckedChangeListener((button, checked) -> enableFields.run());
        enhanced.setOnCheckedChangeListener((button, checked) -> enableFields.run());
        view.findViewById(R.id.homePreloadApply).setOnClickListener(button -> {
            try {
                // 关闭覆盖无需解析已禁用输入框，始终可以恢复代码配置。
                HomePreloadOverrides previous = DramaSettings.getHomePreloadOverrides();
                HomePreloadOverrides next = override.isChecked()
                        ? new HomePreloadOverrides(true, downloads.isChecked(), warmup.isChecked(),
                        enhanced.isChecked(),
                        speed.isEnabled() ? Integer.parseInt(speed.getText().toString().trim())
                                : previous.speedDpPerSecond,
                        interval.isEnabled() ? Integer.parseInt(interval.getText().toString().trim())
                                : previous.updateIntervalMs)
                        : new HomePreloadOverrides(false, previous.downloads, previous.startupWarmup,
                        previous.enhancedWindowEnabled,
                        previous.speedDpPerSecond, previous.updateIntervalMs);
                DramaSettings.setHomePreloadOverrides(next);
                Toast.makeText(requireContext(), R.string.home_preload_applied, Toast.LENGTH_SHORT).show();
            } catch (IllegalArgumentException error) {
                Toast.makeText(requireContext(), R.string.home_preload_invalid, Toast.LENGTH_SHORT).show();
            }
        });
    }
}
