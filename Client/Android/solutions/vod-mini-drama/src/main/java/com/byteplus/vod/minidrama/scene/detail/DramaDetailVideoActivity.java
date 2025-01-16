// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_INPUT;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.R;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class DramaDetailVideoActivity extends BaseActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                false,
                true,
                Color.BLACK,
                false,
                false
        );
        DramaDetailVideoActivityResultContract.Input input = parseInput();
        if (input == null) {
            finish();
            return;
        }
        setContentView(R.layout.vevod_mini_drama_detail_video_activity);
        Fragment fragment;
        if (input.orientation == DramaInfo.Orientation.LANDSCAPE) {
            fragment = new DramaDetailVideoLandscapeFragment();
        } else {
            fragment = new DramaDetailVideoFragment();
        }
        fragment.setArguments(getIntent().getExtras());
        getSupportFragmentManager().beginTransaction()
                .setReorderingAllowed(true)
                .add(R.id.fragment_container, fragment).commit();
    }

    @Nullable
    private DramaDetailVideoActivityResultContract.Input parseInput() {
        Intent intent = getIntent();
        if (intent == null) {
            return null;
        }
        return (DramaDetailVideoActivityResultContract.Input)
                intent.getSerializableExtra(EXTRA_INPUT);
    }
}
