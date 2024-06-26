// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.bytedance.chrous.R;
import com.vertcdemo.solution.chorus.feature.ChorusEntryActivity;

@Keep
public class ChorusEntry implements ISceneEntry {
    @Override
    public int getTitle() {
        return R.string.chorus_scenes;
    }

    @Override
    public int getBackground() {
        return R.drawable.chorus_bg_entry;
    }

    @Override
    public int getDescription() {
        return R.string.chorus_scenes_des;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent();
        intent.setClass(context, ChorusEntryActivity.class);
        context.startActivity(intent);
    }
}
