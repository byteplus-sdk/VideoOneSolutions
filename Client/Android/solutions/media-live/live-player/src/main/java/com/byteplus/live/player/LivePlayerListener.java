// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

public interface LivePlayerListener {
    void onStartPlay();

    void onStopPlay();

    void onPausePlay();

    void onResumePlay();

    void onSwitchResolution(String resolution);

    void onSwitchUrl(String Url);

    void onEnableCycleInfo(boolean enable);

    void onSetLogLevel(int logLevel);

    void onEnableCallbackRecord(boolean enable);

    int onChangeFillMode(int fillMode);

    void onChangeRotation(int rotation);

    void onChangeMirrorMode(int mirrorMode);

    void onSnapShot();



    void onSetVolume(float volume);

    boolean onGetIsMute();

    boolean isPlaying();

    void onSetMute(boolean isMute);

    int onEnableAudioFrameObserver(boolean enable, boolean enableRendering);

    int onEnableVideoFrameObserver(boolean enable, int pixelFormat, int bufferType);
}