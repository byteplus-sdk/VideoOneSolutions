// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import androidx.annotation.NonNull;

import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.solution.interactivelive.core.live.push.LivePusherImpl;

public interface LiveCoreHolder {
    static LiveCoreHolder createLiveCore(boolean video, boolean audio) {
        return LivePusherImpl.create(video, audio);
    }

    static LiveConfigParams getConfigParams() {
        return LivePusherImpl.sLiveParams;
    }

    void startFakeVideo();

    void stopFakeVideo();

    void startFakeAudio();

    void stopFakeAudio();

    void changeConfig(int width, int height, int fps, int defaultBitrate);

    void start(@NonNull RTCVideo rtcVideo, String url);

    void stop(@NonNull RTCVideo rtcVideo);

    void release();

    @NonNull
    StatisticsInfo getStatisticsInfo();
}
