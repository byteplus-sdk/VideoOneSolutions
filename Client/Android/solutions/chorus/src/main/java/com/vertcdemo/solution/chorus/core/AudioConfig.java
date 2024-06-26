// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;

import com.ss.bytertc.engine.type.VoiceReverbType;

/**
 * 声音相关设置
 */
public class AudioConfig {
    public static final int DEFAULT_SONG_VOLUME = 10;
    public static final int DEFAULT_USER_VOLUME = 100;
    public static final int DEFAULT_EAR_MONITOR_VOLUME = 100;

    /***耳返功能是否打开的***/
    private boolean isEarMonitorOpening = false;
    /***耳返音量***/
    private int mEarMonitorVolume = DEFAULT_EAR_MONITOR_VOLUME;
    /***音乐音量***/
    private int mSongVolume = DEFAULT_SONG_VOLUME;
    /***人声音量***/
    private int mUserVolume = DEFAULT_USER_VOLUME;
    /***声音音效***/
    private VoiceReverbType mAudioEffect = VoiceReverbType.VOICE_REVERB_KTV;

    public boolean isEarMonitorOpening() {
        return isEarMonitorOpening;
    }

    public void setEarMonitorOpening(boolean earMonitorOpening) {
        isEarMonitorOpening = earMonitorOpening;
    }

    public int getEarMonitorVolume() {
        return mEarMonitorVolume;
    }

    public void setEarMonitorVolume(int mEarMonitorVolume) {
        this.mEarMonitorVolume = mEarMonitorVolume;
    }

    public int getSongVolume() {
        return mSongVolume;
    }

    public void setSongVolume(int mSongVolume) {
        this.mSongVolume = mSongVolume;
    }

    public int getUserVolume() {
        return mUserVolume;
    }

    public void setUserVolume(int mUserVolume) {
        this.mUserVolume = mUserVolume;
    }

    public VoiceReverbType getAudioEffect() {
        return mAudioEffect;
    }

    public void setAudioEffect(VoiceReverbType mAudioEffect) {
        this.mAudioEffect = mAudioEffect;
    }

    public void copyVolumes(AudioConfig other) {
        this.mEarMonitorVolume = other.mEarMonitorVolume;
        this.mSongVolume = other.mSongVolume;
        this.mUserVolume = other.mUserVolume;
    }
}
