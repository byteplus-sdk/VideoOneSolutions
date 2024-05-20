// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.utils;

import java.util.Formatter;
import java.util.Locale;


public class TimeUtils {

    private static Formatter sFormatter;
    private static StringBuilder sFormatBuilder;

    /**
     * Format time timeMS -> HH:MM:SS
     *
     * @param timeMs time in milliseconds
     */
    public static String time2String(long timeMs) {
        if (timeMs < 0) {
            return ""; //or throw an exception
        }

        long totalSeconds = timeMs / 1000;

        long seconds = totalSeconds % 60;
        long minutes = (totalSeconds / 60) % 60;
        long hours = totalSeconds / 3600;

        if (sFormatter == null) {
            sFormatBuilder = new StringBuilder();
            sFormatter = new Formatter(sFormatBuilder, Locale.getDefault());
        }

        sFormatBuilder.setLength(0);
        if (hours > 0) {
            return sFormatter.format("%02d:%02d:%02d", hours, minutes, seconds).toString();
        } else {
            return sFormatter.format("%02d:%02d", minutes, seconds).toString();
        }
    }
}
