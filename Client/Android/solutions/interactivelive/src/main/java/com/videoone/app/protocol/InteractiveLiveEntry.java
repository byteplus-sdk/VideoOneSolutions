// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.DrawableRes;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.feature.InteractiveLiveEntryActivity;

/**
 * Demo App Entry
 * used by reflection
 */
@Keep
public class InteractiveLiveEntry implements ISceneEntry {
    @DrawableRes
    @Override
    public int getBackground() {
        return R.drawable.interactive_live_bg_entry;
    }

    @StringRes
    @Override
    public int getTitle() {
        return R.string.interactive_live_title;
    }

    @StringRes
    @Override
    public int getDescription() {
        return R.string.interactive_live_description;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent();
        intent.setClass(context, InteractiveLiveEntryActivity.class);
        context.startActivity(intent);
    }
}
