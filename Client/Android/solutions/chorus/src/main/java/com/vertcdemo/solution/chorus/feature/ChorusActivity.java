// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature;


import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;

import com.bytedance.chrous.R;
import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.rts.RTSInfo;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class ChorusActivity extends AppCompatActivity {
    public static final String EXTRA_ROOM_INFO = "roomInfo";
    public static final String EXTRA_USER_INFO = "userInfo";
    public static final String EXTRA_RTC_TOKEN = "rtcToken";
    public static final String EXTRA_REFERRER = "referrer";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Window window = getWindow();
        WindowCompat.setDecorFitsSystemWindows(window, false);

        // for HONOR 50, HTH-AN00, MagicOS 7, Android 12
        // This device need this line to set status bar TRANSPARENT and should called before setStatusBarColor
        window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);

        window.setStatusBarColor(Color.TRANSPARENT);
        window.setNavigationBarColor(Color.TRANSPARENT);

        setContentView(R.layout.activity_chorus);

        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onCreate(@NonNull LifecycleOwner owner) {
                SolutionEventBus.register(owner);
            }

            @Override
            public void onDestroy(@NonNull LifecycleOwner owner) {
                SolutionEventBus.unregister(owner);
            }
        });

        final ChorusViewModel viewModel = new ViewModelProvider(this).get(ChorusViewModel.class);
        viewModel.rtsStatus.observe(this, status -> {
            if (status == ChorusViewModel.RTS_STATUS_NONE) {
                final Intent intent = getIntent();
                viewModel.setRTSInfo(intent.getParcelableExtra(RTSInfo.KEY_RTS));
                viewModel.loginRTS();
            } else if (status == ChorusViewModel.RTS_STATUS_FAILED) {
                finish();
            }
        });
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
