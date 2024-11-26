// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature;

import android.content.Intent;
import android.os.Bundle;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;

import com.bytedance.chrous.R;
import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.bean.RTCAppInfo;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Objects;

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

        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
        controller.setAppearanceLightStatusBars(true);
        controller.setAppearanceLightNavigationBars(true);

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
        viewModel.rtcStatus.observe(this, status -> {
            if (status == ChorusViewModel.RTC_STATUS_NONE) {
                final Intent intent = getIntent();
                RTCAppInfo info = Objects.requireNonNull(intent.getParcelableExtra(RTCAppInfo.KEY_APP_INFO));
                viewModel.setAppInfo(info);
            }
        });
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
