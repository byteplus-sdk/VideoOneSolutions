// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.adapter;

import androidx.core.util.Consumer;

import com.ss.bytertc.engine.video.IVideoSink;
import com.ss.bytertc.engine.video.VideoFrame;

public class VideoSink implements IVideoSink {
    private final Consumer<VideoFrame> mConsumer;

    public VideoSink(Consumer<VideoFrame> consumer) {
        mConsumer = consumer;
    }

    @Override
    public void onFrame(VideoFrame frame) {
        mConsumer.accept(frame);
        frame.release();
    }

    @Override
    public int getRenderElapse() {
        return 0;
    }
}
