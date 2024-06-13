// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.ui.video.layer.FullScreenLayer;

public class ShortVideoFullScreenLayer extends FullScreenLayer {
    @Nullable
    private Runnable mAfterExitFullScreenListener;

    public ShortVideoFullScreenLayer(){
        setEnableToggleFullScreenBySensor(false);
    }

    public void setAfterExitFullScreenListener(@Nullable Runnable runnable) {
        mAfterExitFullScreenListener = runnable;
    }

    @Override
    protected void afterExitFullScreen() {
        if (mAfterExitFullScreenListener != null) {
            mAfterExitFullScreenListener.run();
        }
    }
}
