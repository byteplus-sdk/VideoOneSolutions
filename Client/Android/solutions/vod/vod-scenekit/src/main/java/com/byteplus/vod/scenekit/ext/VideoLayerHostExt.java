// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ext;

import android.content.Context;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.ext.IStrategy;

public class VideoLayerHostExt extends VideoLayerHost {
    private final IStrategy mConfig;

    public VideoLayerHostExt(Context context, IStrategy config) {
        super(context);
        this.mConfig = config;
    }

    @Nullable
    @Override
    public IStrategy getConfig() {
        return mConfig;
    }
}
