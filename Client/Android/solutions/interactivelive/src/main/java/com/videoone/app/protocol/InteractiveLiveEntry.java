// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import android.app.Activity;
import android.content.Intent;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.feature.InteractiveLiveEntryActivity;

import androidx.annotation.DrawableRes;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

/**
 * Demo App Entry
 * used by reflection
 */
@Keep
public class InteractiveLiveEntry {
    @Keep
    @DrawableRes
    public int icon() {
        return R.drawable.interactive_live_icon;
    }

    @Keep
    @StringRes
    public int title() {
        return R.string.interactive_live_title;
    }

    @Keep
    @StringRes
    public int description() {
        return R.string.interactive_live_description;
    }

    @Keep
    public void startup(@NonNull Activity activity) {
        Intent intent = new Intent();
        intent.setClass(activity, InteractiveLiveEntryActivity.class);
        activity.startActivity(intent);
    }
}
