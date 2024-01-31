// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import android.util.Log;

import com.ss.bytertc.engine.live.ByteRTCStreamMixingEvent;
import com.ss.bytertc.engine.live.ByteRTCTranscoderErrorCode;
import com.ss.bytertc.engine.live.IMixedStreamObserver;
import com.ss.bytertc.engine.live.MixedStreamType;
import com.ss.bytertc.engine.video.VideoFrame;

public class MixedStreamObserverAdapter implements IMixedStreamObserver {
    private static final String TAG = "MixedStreamObserver";

    @Override
    public boolean isSupportClientPushStream() {
        return false;
    }

    @Override
    public void onMixingEvent(ByteRTCStreamMixingEvent eventType, String taskId, ByteRTCTranscoderErrorCode error, MixedStreamType mixType) {
        Log.d(TAG, "onMixingEvent: eventType=" + eventType + "; error=" + error + "; mixType=" + mixType);
    }

    @Override
    public void onMixingAudioFrame(String taskId, byte[] audioFrame, int frameNum, long timeStampMs) {

    }

    @Override
    public void onMixingVideoFrame(String taskId, VideoFrame videoFrame) {

    }

    @Override
    public void onMixingDataFrame(String taskId, byte[] dataFrame, long time) {

    }

    @Override
    public void onCacheSyncVideoFrames(String taskId, String[] userIds, VideoFrame[] videoFrame, byte[][] dataFrame, int count) {

    }
}
