// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.source;

import androidx.annotation.NonNull;

import java.util.List;

public interface SubtitleSelector {


    @NonNull
    Subtitle selectSubtitle(@NonNull MediaSource mediaSource, @NonNull List<Subtitle> subtitles);
}
