// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.vertc.api.example.entry.APIExampleTabFragment;
import com.vertc.api.example.entry.R;

@Keep
public class RTCApiExampleFunction implements IFunctionTabEntry {
    @Override
    public int getTitle() {
        return R.string.rtc_example_tab_name;
    }

    @NonNull
    @Override
    public Fragment fragment() {
        return new APIExampleTabFragment();
    }
}
