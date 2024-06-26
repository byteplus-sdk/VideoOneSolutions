// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

/**
 * SDK音量变化事件
 */
public class SDKAudioVolumeEvent {

    public final String userId;

    public final int linearVolume;

    public final boolean isSpeaking;

    public SDKAudioVolumeEvent(String userId, int linearVolume) {
        this.userId = userId;
        this.linearVolume = linearVolume;
        this.isSpeaking = linearVolume > 20;
    }
}
