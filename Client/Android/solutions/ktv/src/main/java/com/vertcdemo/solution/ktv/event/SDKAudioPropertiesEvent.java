// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import androidx.annotation.NonNull;

import com.ss.bytertc.engine.data.AudioPropertiesInfo;
import com.vertcdemo.core.eventbus.SkipLogging;

import java.util.Collections;
import java.util.List;

/**
 * SDK回调用户音量大小变化事件
 */
@SkipLogging
public class SDKAudioPropertiesEvent {

    @NonNull
    public final List<AudioProperties> audioPropertiesList;

    public SDKAudioPropertiesEvent(@NonNull List<AudioProperties> audioPropertiesList) {
        this.audioPropertiesList = audioPropertiesList;
    }

    public SDKAudioPropertiesEvent(AudioProperties audioProperties) {
        this.audioPropertiesList = Collections.singletonList(audioProperties);
    }

    public static class AudioProperties {
        public final String userId;

        public final int linearVolume;

        public AudioProperties(String userId, AudioPropertiesInfo audioPropertiesInfo) {
            this.userId = userId;
            this.linearVolume = audioPropertiesInfo.linearVolume;
        }

        public boolean isSpeaking() {
            return linearVolume > 10;
        }
    }
}