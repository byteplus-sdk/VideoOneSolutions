// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.widget;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;

import androidx.annotation.NonNull;

import com.byteplus.live.common.dialog.SettingsDialog;
import com.byteplus.live.pusher.LivePusher;
import com.byteplus.live.pusher.R;

public class PusherInfoDialog extends SettingsDialog {

    private final LivePusher.InfoListener mInfoListener;

    private final Context mContext;

    public PusherInfoDialog(@NonNull Context context, LivePusher.InfoListener listener) {
        super(context);
        this.mContext = context;
        this.mInfoListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        View view = LayoutInflater.from(mContext)
                .inflate(R.layout.live_pusher_basic_info, mContainer, false);
        CheckBox cycleInfo = view.findViewById(R.id.cycle_info);
        cycleInfo.setOnCheckedChangeListener((button, isChecked) -> {
            mInfoListener.onEnableCycleInfo(isChecked);
        });

        CheckBox callbackRecord = view.findViewById(R.id.callback_info);
        callbackRecord.setOnCheckedChangeListener((button, isChecked) -> {
            mInfoListener.onEnableCallbackRecord(isChecked);
        });

        mContainer.addView(view);
    }
}
