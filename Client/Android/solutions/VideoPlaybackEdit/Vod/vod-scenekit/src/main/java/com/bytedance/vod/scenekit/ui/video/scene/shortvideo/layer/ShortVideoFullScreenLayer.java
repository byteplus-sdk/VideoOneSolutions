package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.ui.video.layer.FullScreenLayer;

public class ShortVideoFullScreenLayer extends FullScreenLayer {
    @Nullable
    private Runnable mAfterExitFullScreenListener;

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
