// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import androidx.annotation.NonNull;

public class LivePlayerCycleInfo {
    public String url;
    public int width;
    public int height;
    public float fps;
    public long videoBitrate;
    public long audioBitrate;
    public long bitrate;
    public String videoCodec;
    public String audioCodec;
    public String protocol;
    public long stallTimeMs;
    public long delayMs;
    public long videoBufferMs;
    public long audioBufferMs;
    public String format;
    public boolean isHardwareDecode;
    public boolean isPlaying;
    public boolean isMute;

    @NonNull
    @Override
    public String toString() {
        return "Url: " + url +
                "\nWidth: " + width +
                "\nHeight: " + height +
                "\nFrame rate: " + fps +
                "\nBitrate: " + bitrate + "kbps" +
                "\nCodec: " + videoCodec +
                "\nStallTime: " + stallTimeMs + "ms" +
                "\nDelay: " + delayMs + "ms" +
                "\nVideo buffer: " + videoBufferMs + "ms" +
                "\nAudio buffer: " + audioBufferMs + "ms" +
                "\nFormat: " + format +
                "\nProtocol: " + protocol +
                "\nDecoder: " + (isHardwareDecode ? "HARDWARE; " : "SOFTWARE; ") +
                "\nStatus: " + (isPlaying ? "PLAYING; " : "NOT PLAY; ") +
                "\nVolume: " + (isMute ? "MUTE; " : "NOT MUTED;");
    }
}
