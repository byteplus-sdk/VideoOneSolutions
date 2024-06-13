// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.DrawableRes;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.byteplus.voddemo.R;
import com.byteplus.voddemo.ui.main.MainTabActivity;
import com.byteplus.voddemo.ui.settings.SettingsActivity;
import com.vertcdemo.ui.CenteredToast;

/**
 * Demo App Entry
 * used by reflection
 */
@Keep
public class PlaybackEditEntry implements ISceneEntry {
    private static final String TAG = "PlaybackEditEntry";

    @DrawableRes
    @Override
    public int getBackground() {
        return R.drawable.vevod_bg_entry;
    }

    @StringRes
    @Override
    public int getTitle() {
        return R.string.vevod_playback_edit_title;
    }

    @StringRes
    @Override
    public int getDescription() {
        return R.string.vevod_playback_edit_description;
    }

    @Override
    public boolean getShowGear() {
        return false;
    }

    @Override
    public void startup(@NonNull Context context) {
        if (PlaybackEditInitializer.initialized) {
            Intent intent = new Intent();
            intent.setClass(context, MainTabActivity.class);
            context.startActivity(intent);
        } else {
            CenteredToast.show("Initializer failed, check PlaybackEditInitializer.java");
            Log.e(TAG, "PlaybackEditInitializer is not initialized correctly, please check the required parameters");
        }
    }

    @Override
    public void startSettings(@NonNull Context context) {
        Intent intent = new Intent();
        intent.setClass(context, SettingsActivity.class);
        context.startActivity(intent);
    }
}
