// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.ss.bytertc.engine.data.PlayerState;

public class AudioMixingStateEvent {

    public enum State {
        PAUSED, PLAYING, STOPPED, FINISHED, OTHER;
    }

    public final State state;

    private AudioMixingStateEvent(State state) {
        this.state = state;
    }

    public static AudioMixingStateEvent of(PlayerState state) {
        switch (state) {
            case FINISHED:
                return new AudioMixingStateEvent(State.FINISHED);
            case PAUSED:
                return new AudioMixingStateEvent(State.PAUSED);
            case PLAYING:
                return new AudioMixingStateEvent(State.PLAYING);
            case STOPPED:
                return new AudioMixingStateEvent(State.STOPPED);
            default:
                return new AudioMixingStateEvent(State.OTHER);
        }
    }
}
