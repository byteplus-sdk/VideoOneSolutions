// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import android.util.Log;

import com.ss.bytertc.engine.live.ByteRTCStreamMixingEvent;
import com.ss.bytertc.engine.live.ByteRTCStreamMixingType;
import com.ss.bytertc.engine.live.ByteRTCTranscoderErrorCode;
import com.ss.bytertc.engine.live.ILiveTranscodingObserver;

import org.webrtc.VideoFrame;

public class LiveTranscodingObserverAdapter implements ILiveTranscodingObserver {
    private static final String TAG = "TranscodingObAdapter";

    /**
     * Whether the client has streaming capability.
     * @return false: Does not have streaming capability (default value)
     */
    @Override
    public boolean isSupportClientPushStream() {
        return false;
    }

    /**
     * Retweet live status callback
     * @param eventType Retweet live task status
     * @param taskId Retweet live task ID
     * @param error Retweet live error code
     * @param mixType Retweet live broadcast type
     */
    @Override
    public void onStreamMixingEvent(ByteRTCStreamMixingEvent eventType, String taskId, ByteRTCTranscoderErrorCode error, ByteRTCStreamMixingType mixType) {
        Log.d(TAG, String.format("onStreamMixingEvent: %s %s", eventType, error));
    }

    @Override
    public void onMixingAudioFrame(String taskId, byte[] audioFrame, int frameNum) {

    }

    @Override
    public void onMixingVideoFrame(String taskId, VideoFrame videoFrame) {

    }

    @Override
    public void onDataFrame(String taskId, byte[] dataFrame, long time) {

    }

}
