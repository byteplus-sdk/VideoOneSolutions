// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core;

import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.video.VideoCaptureConfig;

public class LiveSettingConfig {
    public int width;
    public int height;
    public int frameRate;
    public int bitRate;

    public LiveSettingConfig(int width, int height, int frameRate, int bitRate) {
        this.width = width;
        this.height = height;
        this.frameRate = frameRate;
        this.bitRate = bitRate;
    }

    public VideoCaptureConfig toCaptureConfig() {
        return new VideoCaptureConfig(width, height, frameRate);
    }

    public VideoEncoderConfig toEncoderConfig() {
        VideoEncoderConfig config = new VideoEncoderConfig();
        config.width = width;
        config.height = height;
        config.frameRate = frameRate;
        config.maxBitrate = bitRate;
        return config;
    }
}
