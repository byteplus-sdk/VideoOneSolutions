// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

public class LiveConfigParams {
    public int width;
    public int height;
    public int fps;
    public int defaultBitrate;
    public int minBitrate;
    public int maxBitrate;

    public void videoResolution(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public void videoFps(int fps) {
        this.fps = fps;
    }

    public void videoBitrate(int defaultBitrate, int minBitrate, int maxBitrate) {
        this.defaultBitrate = defaultBitrate;
        this.minBitrate = minBitrate;
        this.maxBitrate = maxBitrate;
    }
}
