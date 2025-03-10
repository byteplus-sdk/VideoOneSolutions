// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.HyperOS;
import com.vertcdemo.solution.ktv.R;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class KTVActivity extends AppCompatActivity {
    public static final String EXTRA_ROOM_INFO = "roomInfo";
    public static final String EXTRA_USER_INFO = "userInfo";
    public static final String EXTRA_RTC_TOKEN = "rtcToken";
    public static final String EXTRA_REFERRER = "referrer";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        EdgeToEdge.enable(this);
        HyperOS.fixNavigationBar(this);

        setContentView(R.layout.activity_ktv);

        SolutionEventBus.register(this);
    }

    @Override
    protected void onDestroy() {
        SolutionEventBus.unregister(this);
        super.onDestroy();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
