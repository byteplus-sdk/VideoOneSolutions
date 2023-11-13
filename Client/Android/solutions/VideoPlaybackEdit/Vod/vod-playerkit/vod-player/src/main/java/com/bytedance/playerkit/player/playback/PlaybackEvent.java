// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.playback;

public interface PlaybackEvent {

    class Action {
        public static final int PREPARE_PLAYBACK = 10001;
        public static final int START_PLAYBACK = 10002;
        public static final int STOP_PLAYBACK = 10003;
    }

    class State {
        public static final int BIND_PLAYER = 20001;
        public static final int UNBIND_PLAYER = 20002;
        public static final int BIND_VIDEO_VIEW = 20003;
        public static final int UNBIND_VIDEO_VIEW = 20004;
    }
}
