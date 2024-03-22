// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.ss.bytertc.engine.data.AudioMixingState;

public class AudioMixingStateEvent {
    public final AudioMixingState state;

    public AudioMixingStateEvent(AudioMixingState state) {
        this.state = state;
    }
}
