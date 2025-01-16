// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.input.media;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.vod.input.media.utils.SampleSourceParser;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;

import java.util.ArrayList;

public class SampleSourceActivity extends BaseActivity {
    public static final String ACTION_INPUT_MEDIA_SOURCE = "com.byteplus.vod.scenekit.action.INPUT_MEDIA_SOURCE";

    private SharedPreferences mSp;
    private EditText mEditText;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.vevod_sample_source);

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
            actionBar.setTitle(com.byteplus.vod.scenekit.R.string.vevod_option_debug_input_media_source);
        }

        UIUtils.setSystemBarTheme(
                this,
                Color.WHITE,
                true,
                false,
                Color.WHITE,
                true,
                false
        );

        mEditText = findViewById(R.id.input);

        restore();
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onDestroy() {
        save();
        super.onDestroy();
    }

    private void save() {
        final EditText editText = findViewById(R.id.input);
        final Editable editable = editText.getText();

        final String input = editable == null ? "" : editable.toString();
        final String recorded = mSp.getString("input", null);
        if (!TextUtils.equals(input, recorded)) {
            mSp.edit().putString("input", input).apply();
        }
    }

    private void restore() {
        mSp = getSharedPreferences("vod_demo_media_source", Context.MODE_PRIVATE);
        String input = mSp.getString("input", null);

        if (!TextUtils.isEmpty(input)) {
            mEditText.setText(input);
        }
    }

    public void onFeedVideoClick(View view) {
        ArrayList<VideoItem> videoItems = buildVideoItemsWithInput();
        if (videoItems == null) return;
        SampleFeedVideoActivity.intentInto(this, videoItems);
    }

    public void onShortVideoClick(View view) {
        ArrayList<VideoItem> videoItems = buildVideoItemsWithInput();
        if (videoItems == null) return;
        SampleShortVideoActivity.intentInto(this, videoItems);
    }

    @Nullable
    private ArrayList<VideoItem> buildVideoItemsWithInput() {
        final Editable editable = mEditText.getText();
        if (TextUtils.isEmpty(editable)) {
            mEditText.setError("Empty!");
            return null;
        }
        final String input = editable.toString();

        ArrayList<VideoItem> videoItems = SampleSourceParser.parse(input);
        if (videoItems.isEmpty()) {
            mEditText.setError("JSON is invalid.");
            return null;
        }
        return videoItems;
    }

    public void onCleanCacheClick(View view) {
        Toast.makeText(this, "Cleaning cache...", Toast.LENGTH_SHORT).show();
        CacheLoader.Default.get().clearCache();
        Toast.makeText(this, "Clean done!", Toast.LENGTH_SHORT).show();
    }
}