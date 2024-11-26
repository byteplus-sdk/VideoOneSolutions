package com.vertcdemo.core.ui;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.rtc.toolkit.R;
import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class SolutionLoadingActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_solution_loading);

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
