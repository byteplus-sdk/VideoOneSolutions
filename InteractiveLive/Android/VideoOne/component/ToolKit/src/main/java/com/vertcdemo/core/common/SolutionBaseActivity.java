// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.common;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.core.net.http.AppNetworkStatus;
import com.vertcdemo.core.net.http.AppNetworkStatusEvent;
import com.vertcdemo.core.net.http.AppNetworkStatusUtil;
import com.vertcdemo.core.net.http.TopTipView;
import com.vertcdemo.core.utils.Activities;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Locale;

public class SolutionBaseActivity extends AppCompatActivity {

    private static final String TAG = "SolutionBaseActivity";

    private static final String RECORD_KEY_LOCALE = "extra_locale";

    private TopTipView mTopTipView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Activities.transparentStatusBar(this);

        if (checkIfLocaleChanged(savedInstanceState)) {
            Log.d(TAG, "checkIfLocaleChanged() finish");
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        checkAndShowNetworkDisconnect();
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        recordLocale(outState);
    }

    /**
     * Record current system default locale
     * @param outState The record data object provided by the system
     */
    private void recordLocale(@NonNull Bundle outState) {
        String currentLanguage = Locale.getDefault().getLanguage();
        Log.d(TAG, String.format("recordLocale: %s", currentLanguage));
        outState.putString(RECORD_KEY_LOCALE, currentLanguage);
    }

    /**
     * Check system default locale changes
     * @param savedInstanceState data saved by the system
     * @return true: changed
     */
    private boolean checkIfLocaleChanged(@Nullable Bundle savedInstanceState) {
        if (savedInstanceState == null) {
            return false;
        }
        String currentLocale = Locale.getDefault().getLanguage();
        return !TextUtils.equals(savedInstanceState.getString(RECORD_KEY_LOCALE), currentLocale);
    }

    protected void checkAndShowNetworkDisconnect() {
        if (AppNetworkStatusUtil.isConnected(getApplicationContext())) {
            onNetworkAvailable();
        } else {
            onNetworkUnavailable();
        }
    }

    private void onNetworkAvailable() {
        Log.d(TAG, "onNetworkAvailable()");
        if (mTopTipView != null) {
            mTopTipView.setVisibility(View.GONE);
            ViewGroup rootView = findViewById(android.R.id.content);
            if (rootView != null) {
                rootView.removeView(mTopTipView);
            }
        }
    }

    private void onNetworkUnavailable() {
        Log.d(TAG, "onNetworkUnavailable()");
        if (mTopTipView == null) {
            mTopTipView = new TopTipView(this);
            ViewGroup rootView = findViewById(android.R.id.content);
            if (rootView != null) {
                rootView.addView(mTopTipView);
            }
        }
        mTopTipView.setNetworkDisconnect();
        mTopTipView.bringToFront();
        mTopTipView.setVisibility(View.VISIBLE);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onNetworkStatusChanged(AppNetworkStatusEvent event) {
        if (event.status == AppNetworkStatus.CONNECTED) {
            onNetworkAvailable();
        } else if (event.status == AppNetworkStatus.DISCONNECTED) {
            onNetworkUnavailable();
        }
    }
}
