// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.adapter;

import androidx.core.util.Consumer;

import com.ss.bytertc.engine.IAudioFrameObserver;
import com.ss.bytertc.engine.data.StreamInfo;
import com.ss.bytertc.engine.utils.IAudioFrame;

public class AudioSink implements IAudioFrameObserver {
    private final Consumer<IAudioFrame> mConsumer;

    public AudioSink(Consumer<IAudioFrame> consumer) {
        mConsumer = consumer;
    }

    @Override
    public void onRecordAudioFrame(IAudioFrame audioFrame) {
        mConsumer.accept(audioFrame);
    }

    @Override
    public void onPlaybackAudioFrame(IAudioFrame audioFrame) {

    }

    @Override
    public void onRemoteUserAudioFrame(String roomId, StreamInfo streamInfo, IAudioFrame audioFrame) {

    }

    @Override
    public void onMixedAudioFrame(IAudioFrame audioFrame) {

    }

    @Override
    public void onCaptureMixedAudioFrame(IAudioFrame audioFrame) {

    }
}
