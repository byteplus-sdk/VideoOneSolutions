// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.byteplus.live.entrance.R;
import com.byteplus.live.entrance.UIMainActivity;

@Keep
public class FunctionMediaLive implements IFunctionEntry {
    @Override
    public int getTitle() {
        return R.string.medialive_entry_title;
    }

    @Override
    public int getIcon() {
        return R.drawable.live_ic_entry_media_live;
    }

    @Override
    public int getDescription() {
        return R.string.medialive_entry_des;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent(context, UIMainActivity.class);
        context.startActivity(intent);
    }
}
