// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.event;

import androidx.annotation.NonNull;

/**
 * RTC 用户开始或者停止视频采集事件
 */
public class UserVideoEvent {
    public String uid;
    public boolean hasVideo;

    public UserVideoEvent(String uid, boolean hasVideo) {
        this.hasVideo = hasVideo;
        this.uid = uid;
    }

    @NonNull
    @Override
    public String toString() {
        return "UserVideoEvent{" +
                ", uid='" + uid + '\'' +
                "hasVideo=" + hasVideo +
                '}';
    }
}
