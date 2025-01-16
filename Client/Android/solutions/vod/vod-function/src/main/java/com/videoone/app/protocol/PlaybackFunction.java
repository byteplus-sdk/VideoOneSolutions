// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.byteplus.vodfunction.R;
import com.videoone.vod.function.fragment.PlaybackFunctionFragment;

@Keep
public class PlaybackFunction implements IFunctionTabEntry{
    @Override
    public int getTitle() {
        return R.string.vevod_video_playback_tab_name;
    }

    @NonNull
    @Override
    public Fragment fragment() {
        return new PlaybackFunctionFragment();
    }
}
