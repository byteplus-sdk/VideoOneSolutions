// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.main;

import android.graphics.Color;
import android.os.Bundle;

import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;
import com.byteplus.voddemo.R;
import com.byteplus.voddemo.utils.OuterActionsHelper;

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

        setContentView(R.layout.vevod_main_tab_activity);
        OuterActionsHelper.setup();
    }
}
