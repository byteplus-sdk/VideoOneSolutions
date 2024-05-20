// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;

import androidx.annotation.NonNull;

import com.byteplus.live.player.LivePlayerListener;
import com.byteplus.live.player.R;
import com.byteplus.live.settings.PreferenceUtil;

public class PlayInfoLayout {
    public static View create(@NonNull Context context, @NonNull LivePlayerListener listener) {
        PreferenceUtil prefs = PreferenceUtil.getInstance();

        View root = LayoutInflater.from(context).inflate(R.layout.live_player_basic_info, null);
        {
            CheckBox cycleInfo = root.findViewById(R.id.cycle_info);
            cycleInfo.setChecked(prefs.getPullEnableCycleInfo(false));
            cycleInfo.setOnCheckedChangeListener((button, isChecked) -> {
                listener.onEnableCycleInfo(isChecked);
                prefs.setPullEnableCycleInfo(isChecked);
            });
        }

        {
            CheckBox callbackInfo = root.findViewById(R.id.callback_info);
            callbackInfo.setChecked(prefs.getPullEnableCallbackInfo(false));
            callbackInfo.setOnCheckedChangeListener((button, isChecked) -> {
                listener.onEnableCallbackRecord(isChecked);
                prefs.setPullEnableCallbackInfo(isChecked);
            });
        }
        return root;
    }
}
