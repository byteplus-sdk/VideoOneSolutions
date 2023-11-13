// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.utils;

import java.util.HashMap;
import java.util.Map;


public class ProgressRecorder {

    private static final Map<String, Long> map = new HashMap<>();

    public static void recordProgress(String key, long progress) {
        if (progress >= 0) {
            map.put(key, progress);
        }
    }

    public static void removeProgress(String key) {
        if (key == null) return;
        map.remove(key);
    }

    public static long getProgress(String key) {
        if (key == null) return -1;
        final Long value = map.get(key);
        if (value == null) return -1;
        return value;
    }
}
