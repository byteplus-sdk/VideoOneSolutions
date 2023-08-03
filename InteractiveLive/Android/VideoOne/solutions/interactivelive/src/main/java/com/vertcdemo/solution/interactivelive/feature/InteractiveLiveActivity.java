// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.lifecycle.ViewModelProvider;

import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.solution.interactivelive.R;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class InteractiveLiveActivity extends AppCompatActivity {
    public static final String EXTRA_ROOM_ID = "roomId";
    public static final String EXTRA_HOST_ID = "hostId";
    public static final String EXTRA_ROOM_INFO = "roomInfo";
    public static final String EXTRA_USER_INFO = "userInfo";
    public static final String EXTRA_PUSH_URL = "pushUrl";
    public static final String EXTRA_RTS_TOKEN = "rtsToken";
    public static final String EXTRA_RTC_TOKEN = "rtcToken";
    public static final String EXTRA_RTC_ROOM_ID = "rtcRoomId";

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
        setContentView(R.layout.activity_interactive_live);
        SolutionEventBus.register(this);

        final InteractiveLiveViewModel viewModel = new ViewModelProvider(this).get(InteractiveLiveViewModel.class);
        viewModel.rtsStatus.observe(this, status -> {
            if (status == InteractiveLiveViewModel.RTS_STATUS_NONE) {
                final Intent intent = getIntent();
                viewModel.setRTSInfo(intent.getParcelableExtra(RTSInfo.KEY_RTS));
                viewModel.loginRTS();
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
