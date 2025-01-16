// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;

import com.byteplus.vod.minidrama.scene.main.DramaMainActivity;
import com.byteplus.minidrama.R;

import org.jetbrains.annotations.NotNull;

@Keep
public class MiniDramaEntry implements ISceneEntry {
    @Override
    public int getTitle() {
        return R.string.vevod_mini_drama_entry_title;
    }

    @Override
    public int getBackground() {
        return R.drawable.vevod_mini_drama_entry_bg;
    }

    @Override
    public int getDescription() {
        return R.string.vevod_mini_drama_entry_description;
    }

    @Override
    public void startup(@NotNull Context context) {
        Intent intent = new Intent(context, DramaMainActivity.class);
        context.startActivity(intent);
    }
}
