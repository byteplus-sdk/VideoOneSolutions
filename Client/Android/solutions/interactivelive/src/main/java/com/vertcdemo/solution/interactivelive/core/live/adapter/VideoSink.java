// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.adapter;

import androidx.core.util.Consumer;

import com.ss.bytertc.engine.video.IVideoSink;
import com.ss.bytertc.engine.video.IVideoFrame;

public class VideoSink implements IVideoSink {
    private final Consumer<IVideoFrame> mConsumer;

    public VideoSink(Consumer<IVideoFrame> consumer) {
        mConsumer = consumer;
    }

    @Override
    public void onFrame(IVideoFrame frame) {
        mConsumer.accept(frame);
        frame.releaseRef();
    }

    @Override
    public int getRenderElapse() {
        return 0;
    }
}
