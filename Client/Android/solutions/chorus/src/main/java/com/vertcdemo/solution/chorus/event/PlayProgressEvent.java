// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

/**
 * EventBus播放进度事件
 */
public class PlayProgressEvent {
    public long progress;

    public PlayProgressEvent(long progress) {
        this.progress = progress;
    }
}
