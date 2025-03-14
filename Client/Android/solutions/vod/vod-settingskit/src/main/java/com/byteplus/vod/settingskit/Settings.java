// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.settingskit;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Settings {

    private static final Map<String, List<SettingItem>> sMap = new HashMap<>();

    public static synchronized void put(String key, List<SettingItem> settings) {
        sMap.put(key, settings);
    }

    public static synchronized List<SettingItem> get(String key) {
        return sMap.get(key);
    }
}
