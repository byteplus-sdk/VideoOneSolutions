// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core;

import com.ss.bytertc.engine.type.VoiceReverbType;

public interface Defaults {
    int MUSIC_VOLUME = 10;
    int VOCAL_VOLUME = 100;
    int EAR_MONITOR_VOLUME = 100;

    VoiceReverbType VOICE_REVERB_TYPE = VoiceReverbType.VOICE_REVERB_KTV;
}
