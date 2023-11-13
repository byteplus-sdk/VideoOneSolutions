// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.base;

import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.bytedance.playerkit.utils.L;


public class BaseActivity extends AppCompatActivity {

    @Override
    @CallSuper
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        L.d(this, "onCreate");
    }

    @Override
    @CallSuper
    protected void onStart() {
        super.onStart();
        L.d(this, "onStart");
    }

    @Override
    @CallSuper
    protected void onResume() {
        super.onResume();
        L.d(this, "onResume");
    }

    @Override
    @CallSuper
    protected void onPause() {
        super.onPause();
        L.d(this, "onPause");
    }

    @Override
    @CallSuper
    protected void onStop() {
        super.onStop();
        L.d(this, "onStop");
    }

    @Override
    @CallSuper
    protected void onDestroy() {
        super.onDestroy();
        L.d(this, "onDestroy");
    }

    @Override
    public void onBackPressed() {
        L.d(this, "onBackPressed");
        super.onBackPressed();
    }

    @Override
    public void finish() {
        super.finish();
        L.d(this, "finish");
    }
}
