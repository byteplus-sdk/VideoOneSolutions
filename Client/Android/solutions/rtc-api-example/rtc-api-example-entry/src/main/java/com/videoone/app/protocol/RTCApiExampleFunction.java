// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.vertc.api.example.entry.APIExampleEntryActivity;
import com.vertc.api.example.entry.R;

public class RTCApiExampleFunction implements IFunctionEntry {
    @Override
    public int getTitle() {
        return R.string.rtc_example_entry_name;
    }

    @Override
    public int getIcon() {
        return R.drawable.rtc_example_function_entry;
    }

    @Override
    public int getDescription() {
        return R.string.rtc_example_entry_desc;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent(context, APIExampleEntryActivity.class);
        context.startActivity(intent);
    }
}
