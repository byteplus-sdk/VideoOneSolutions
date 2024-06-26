// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.vertcdemo.solution.karaoke.KaraokeScenesActivity;
import com.vertcdemo.solution.ktv.R;

@Keep
public class KTVEntry implements ISceneEntry {
    @Override
    public int getTitle() {
        return R.string.ktv_scenes;
    }

    @Override
    public int getBackground() {
        return R.drawable.ktv_bg_entry;
    }

    @Override
    public int getDescription() {
        return R.string.ktv_scenes_des;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent(context, KaraokeScenesActivity.class);
        context.startActivity(intent);
    }
}
