// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol;

import static com.videoone.vod.function.VodFunctionActivity.EXTRA_FUNCTION;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.byteplus.vodfunction.R;
import com.videoone.vod.function.Function;
import com.videoone.vod.function.VodFunctionDispatchActivity;

@Keep
public class FunctionVideoPlayback implements IFunctionEntry {
    @Override
    public int getTitle() {
        return R.string.vevod_function_playback_title;
    }

    @Override
    public int getIcon() {
        return R.drawable.vevod_function_video_playback;
    }

    @Override
    public int getDescription() {
        return R.string.vevod_function_playback_desc;
    }

    @Override
    public void startup(@NonNull Context context) {
        Intent intent = new Intent(context, VodFunctionDispatchActivity.class);
        intent.putExtra(EXTRA_FUNCTION, Function.VIDEO_PLAYBACK);
        context.startActivity(intent);
    }
}
