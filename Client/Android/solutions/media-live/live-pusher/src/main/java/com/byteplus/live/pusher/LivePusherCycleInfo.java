// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import androidx.annotation.NonNull;

public class LivePusherCycleInfo {
    public String url;
    public int captureWidth;
    public int captureHeight;
    public int encodeWidth;
    public int encodeHeight;
    public double captureFps;
    public double encodeFps;
    public double transportFps;
    public float fps;
    public long videoBitrate;
    public long minVideoBitrate;
    public long maxVideoBitrate;
    public double encodeVideoBitrate;
    public double transportVideoBitrate;
    public double encodeAudioBitrate;
    public String videoCodec;

    @NonNull
    @Override
    public String toString() {
        return "Url: " + url + "\n" +
                "\nCapture Width: " + captureWidth +
                "\nCapture Height: " + captureHeight +
                "\nCapture FPS: " + captureFps +
                "\nEncode Width: " + encodeWidth +
                "\nEncode Height: " + encodeHeight +
                "\nEncode FPS: " + encodeFps +
                "\nTransport FPS: " + transportFps +
                "\nPush FPS: " + fps +
                "\nPush Bitrate: " + (videoBitrate / 1000) + " kbps" +
                "\nPush Bitrate(min.): " + (minVideoBitrate / 1000) + " kbps" +
                "\nPush Bitrate(max.): " + (maxVideoBitrate / 1000) + " kbps" +
                "\nEncode Video Bitrate: " + (encodeVideoBitrate / 1000) + " kbps" +
                "\nTransport Video Bitrate: " + (transportVideoBitrate / 1000) + " kbps" +
                "\nEncode Audio Bitrate: " + (encodeAudioBitrate / 1000) + " kbps" +
                "\nEncode format: " + ("bytevc1".equals(videoCodec) ? "h265" : "h264");
    }
}
