// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.main;

import android.graphics.Color;
import android.os.Bundle;

import com.bytedance.vod.scenekit.ui.base.BaseActivity;
import com.bytedance.vod.scenekit.utils.UIUtils;

public class MainTabActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                true,
                true,
                Color.WHITE,
                true,
                false
        );

        if (savedInstanceState == null) {
            getSupportFragmentManager()
                    .beginTransaction()
                    .add(android.R.id.content, MainTabFragment.newInstance(getIntent().getExtras()))
                    .commit();
        }
    }
}
