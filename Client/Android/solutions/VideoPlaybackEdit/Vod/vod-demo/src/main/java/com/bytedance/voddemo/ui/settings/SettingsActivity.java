// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.settings;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.MenuItem;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import androidx.core.content.res.ResourcesCompat;

import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.ui.base.BaseActivity;
import com.bytedance.vod.settingskit.SettingsFragment;
import com.bytedance.voddemo.impl.R;

public class SettingsActivity extends BaseActivity {

    public static void intentInto(Activity activity) {
        Intent intent = new Intent(activity, SettingsActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.vevod_settings_activity);

        UIUtils.setSystemBarTheme(
                this,
                Color.WHITE,
                true,
                false,
                Color.WHITE,
                true,
                false
        );

        Toolbar toolbar = findViewById(R.id.toolbar);
        toolbar.setNavigationIcon(ContextCompat.getDrawable(this, R.drawable.vevod_actionbar_back));
        int color = ContextCompat.getColor(this, android.R.color.black);
        toolbar.setTitleTextColor(color);
        toolbar.setBackgroundColor(Color.WHITE);
        if (toolbar.getNavigationIcon() != null) {
            toolbar.getNavigationIcon().setTint(color);
        }

        setSupportActionBar(toolbar);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setTitle(R.string.vevod_settings_activity_title);
        }

        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction().add(R.id.container,
                    SettingsFragment.newInstance(VideoSettings.KEY)).commit();
        }
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
