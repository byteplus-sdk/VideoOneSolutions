// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.strategy;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.player.volcengine.VolcSubtitleSelector;

import java.util.List;

public class VideoSubtitle {
    public static final int LANGUAGE_ID_CN = 1;  // 简体中文
    public static final int LANGUAGE_ID_US = 2;  // 英语

    @NonNull
    public static String subtitle2String(Subtitle subtitle) {
        switch (subtitle.getLanguageId()) {
            case LANGUAGE_ID_CN:
                return "CHINESE";
            case LANGUAGE_ID_US:
                return "ENGLISH";
        }
        return "";
    }

    public static List<Integer> createLanguageIds() {
        return VolcSubtitleSelector.DEFAULT_LANGUAGE_IDS;
    }
}

