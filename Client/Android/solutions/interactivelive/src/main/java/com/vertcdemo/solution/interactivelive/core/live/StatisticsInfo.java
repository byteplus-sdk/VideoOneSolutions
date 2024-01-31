// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

public class StatisticsInfo {
    public double encodeFps;
    public double transportFps;
    public double encodeVideoBitrate;
    public double transportVideoBitrate;

    public double getVideoTransportRealFps() {
        return transportFps;
    }

    public double getVideoTransportRealBps() {
        return transportVideoBitrate;
    }

    public double getVideoEncodeRealFps() {
        return encodeFps;
    }

    public double getVideoEncodeRealBps() {
        return encodeVideoBitrate;
    }
}
