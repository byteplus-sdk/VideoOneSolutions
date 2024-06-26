// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room.bean;

import androidx.annotation.Nullable;

import com.vertcdemo.solution.chorus.bean.UserInfo;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;

public class SingerData {
    public static SingerData create(@Nullable UserInfo info) {
        if (info == null) {
            return empty;
        } else {
            return new SingerData(info, ChorusRTCManager.ins().hasVideo(info.userId));
        }
    }

    public static final SingerData empty = new SingerData();

    public final UserInfo info;
    public final boolean hasVideo;

    @Nullable
    public String getUserId() {
        return info == null ? null : info.userId;
    }

    public boolean isMicOn() {
        return info != null && info.isMicOn();
    }

    public SingerData(UserInfo info, boolean hasVideo) {
        this.info = info;
        this.hasVideo = hasVideo;
    }

    public SingerData() {
        this(null, false);
    }

    public SingerData copy(boolean hasVideo) {
        return new SingerData(this.info, hasVideo);
    }
}
