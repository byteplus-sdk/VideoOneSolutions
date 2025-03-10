// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.bytedance.chrous.R;
import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.HyperOS;

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

        EdgeToEdge.enable(this);
        HyperOS.fixNavigationBar(this);

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
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
