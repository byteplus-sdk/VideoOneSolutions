// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import android.view.SurfaceView;
import android.widget.FrameLayout;

import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VideoLiveManager;


public interface LivePlayer {
    void setSurfaceView(SurfaceView surfaceView);

    void setSurfaceContainer(FrameLayout container);

    void startPlay();

    void stopPlay();

    void pause();

    void resume();

    void destroy();

    void switchResolution(String resolution);

    void setVolume(float volume);

    void setMute(boolean isMute);

    boolean isMute();

    boolean isPlaying();

    void switchUrl(String url);

    int setRenderFillMode(int mode);

    void setRenderRotation(VeLivePlayerDef.VeLivePlayerRotation rotation);

    void setRenderMirror(VeLivePlayerDef.VeLivePlayerMirror mirror);

    void snapshot();

    int enableVideoFrameObserver(boolean enable, VeLivePlayerDef.VeLivePlayerPixelFormat pixelFormat, VeLivePlayerDef.VeLivePlayerVideoBufferType bufferType);

    int enableAudioFrameObserver(boolean enable, boolean enableRendering);

    static String getVersion() {
        return VideoLiveManager.getVersion();
    }
}
