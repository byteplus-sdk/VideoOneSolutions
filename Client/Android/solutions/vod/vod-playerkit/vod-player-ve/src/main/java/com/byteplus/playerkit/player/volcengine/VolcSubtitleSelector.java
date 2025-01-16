// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Subtitle;
import com.byteplus.playerkit.player.source.SubtitleSelector;

import java.util.Arrays;
import java.util.List;

/**
 * <a href="https://www.volcengine.com/docs/4/70518#%E5%AD%97%E5%B9%95%E8%AF%AD%E8%A8%80">Language IDs</a>
 */
public class VolcSubtitleSelector implements SubtitleSelector {
    public static final List<Integer> DEFAULT_LANGUAGE_IDS = Arrays.asList(5, 1, 2);

    @NonNull
    @Override
    public Subtitle selectSubtitle(@NonNull MediaSource mediaSource, @NonNull List<Subtitle> subtitles) {
        for (int languageId : DEFAULT_LANGUAGE_IDS) {
            for (Subtitle subtitle : subtitles) {
                if (subtitle.getLanguageId() == languageId) {
                    return subtitle;
                }
            }
        }
        return subtitles.get(0);
    }
}
