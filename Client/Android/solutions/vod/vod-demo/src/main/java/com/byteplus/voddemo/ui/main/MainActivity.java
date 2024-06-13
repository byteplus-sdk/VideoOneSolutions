// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.main;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;

import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class MainActivity extends BaseActivity {

    public static void intentInto(Activity activity, boolean showActionBar) {
        Intent intent = new Intent(activity, MainActivity.class);
        Bundle bundle = new Bundle();
        bundle.putBoolean(MainFragment.EXTRA_SHOW_ACTION_BAR, showActionBar);
        intent.putExtras(bundle);
        activity.startActivity(intent);
    }

    private boolean mShowActionBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mShowActionBar = getIntent().getBooleanExtra(MainFragment.EXTRA_SHOW_ACTION_BAR, false);

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
                    .add(android.R.id.content, MainFragment.newInstance(getIntent().getExtras()))
                    .commit();
        }
    }


    @Override
    public void onBackPressed() {
        if (mShowActionBar) {
            super.onBackPressed();
        } else {
            final Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_HOME);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
    }
}