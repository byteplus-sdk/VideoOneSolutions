// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;

import com.byteplus.minidrama.R;
import com.byteplus.vod.minidrama.scene.main.DramaWithAdsMainActivity;

import org.jetbrains.annotations.NotNull;

@Keep
public class MiniDramaWithAdsEntry implements ISceneEntry {
    @Override
    public int getTitle() {
        return R.string.vevod_mini_drama_with_ads_entry_title;
    }

    @Override
    public int getBackground() {
        return R.drawable.vevod_mini_drama_with_ads_entry_bg;
    }

    @Override
    public int getDescription() {
        return R.string.vevod_mini_drama_with_ads_entry_description;
    }

    @Override
    public void startup(@NotNull Context context) {
        Intent intent = new Intent(context, DramaWithAdsMainActivity.class);
        context.startActivity(intent);
    }
}
