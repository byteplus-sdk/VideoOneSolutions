// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import android.text.TextUtils;

import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;

public class LinkedAudienceItem {
    public LiveUserInfo info;
    public boolean cameraOn;
    public boolean microphoneOn;

    public LinkedAudienceItem(LiveUserInfo user) {
        this.info = user;
        this.cameraOn = user.isCameraOn();
        this.microphoneOn = user.isMicOn();
    }

    public boolean areContentsTheSame(LinkedAudienceItem other) {
        return TextUtils.equals(info.roomId, other.info.roomId)
                && TextUtils.equals(info.userId, other.info.userId)
                && TextUtils.equals(info.userName, other.info.userName)
                && cameraOn == other.cameraOn && microphoneOn == other.microphoneOn;
    }

    public void updateMediaStatus(UserMediaChangedEvent event) {
        if (event.camera == MediaStatus.ON) {
            this.cameraOn = true;
        } else if (event.camera == MediaStatus.OFF) {
            this.cameraOn = false;
        }

        if (event.mic == MediaStatus.ON) {
            this.microphoneOn = true;
        } else if (event.mic == MediaStatus.OFF) {
            this.microphoneOn = false;
        }
    }
}
