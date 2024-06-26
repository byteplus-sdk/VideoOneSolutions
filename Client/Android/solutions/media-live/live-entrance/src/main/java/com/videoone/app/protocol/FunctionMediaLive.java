// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.byteplus.live.entrance.MediaLiveFunctionFragment;
import com.byteplus.live.entrance.R;

@Keep
public class FunctionMediaLive implements IFunctionTabEntry {
    @Override
    public int getTitle() {
        return R.string.medialive_entry_title;
    }

    @NonNull
    @Override
    public Fragment fragment() {
        return new MediaLiveFunctionFragment();
    }
}
