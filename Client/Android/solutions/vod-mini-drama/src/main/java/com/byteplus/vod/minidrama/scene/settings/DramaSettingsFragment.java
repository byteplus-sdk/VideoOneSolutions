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
}
