// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.RTSLogoutEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.Activities;
import com.vertcdemo.login.ILoginImpl;
import com.videoone.app.protocol.InitializeManager;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    @NonNull
    private final ILoginImpl mLogin = new ILoginImpl();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Activities.transparentStatusBar(this);
        mLogin.showLoginView(loginLauncher);
        setContentView(R.layout.activity_main);
        SolutionEventBus.register(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        mLogin.showLoginView(loginLauncher);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRTSLogoutEvent(RTSLogoutEvent event) {
        Log.d(TAG, "onRTSLogoutEvent");
        finishOtherActivity();
        Toast.makeText(this, R.string.same_logged_in, Toast.LENGTH_LONG).show();
        SolutionDataManager.ins().logout();
        SolutionEventBus.post(new AppTokenExpiredEvent());
    }

    private void finishOtherActivity() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
    }

    final ActivityResultLauncher<Intent> loginLauncher =
            registerForActivityResult(
                    new ActivityResultContracts.StartActivityForResult(),
                    result -> {
                        if (result.getResultCode() != RESULT_OK) {
                            Log.e(TAG, "login canceled.");
                            finish();
                        } else {
                            InitializeManager.initialize((Application) getApplicationContext());
                        }
                    });
}
