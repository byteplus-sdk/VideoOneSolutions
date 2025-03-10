// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.HyperOS;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.live.TTSdkHelper;

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

        EdgeToEdge.enable(this);
        HyperOS.fixNavigationBar(this);

        TTSdkHelper.initTTVodSdk();

        setContentView(R.layout.activity_interactive_live);

        SolutionEventBus.register(this);
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
