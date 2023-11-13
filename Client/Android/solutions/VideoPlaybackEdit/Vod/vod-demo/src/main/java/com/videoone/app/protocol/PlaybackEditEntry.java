// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.DrawableRes;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.bytedance.voddemo.impl.R;
import com.bytedance.voddemo.ui.main.MainTabActivity;

/**
 * Demo App Entry
 * used by reflection
 */
@Keep
public class PlaybackEditEntry {

    @Keep
    @DrawableRes
    public int icon() {
        return R.drawable.vevod_playback_edit_icon;
    }

    @Keep
    @StringRes
    public int title() {
        return R.string.vevod_playback_edit_title;
    }

    @Keep
    @StringRes
    public int description() {
        return R.string.vevod_playback_edit_description;
    }

    @Keep
    public void startup(@NonNull Activity activity) {
        Intent intent = new Intent();
        intent.setClass(activity, MainTabActivity.class);
        activity.startActivity(intent);
    }
}
