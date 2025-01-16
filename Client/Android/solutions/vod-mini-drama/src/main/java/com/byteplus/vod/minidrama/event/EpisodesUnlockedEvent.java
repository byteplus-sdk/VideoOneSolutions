// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

import com.byteplus.vod.minidrama.remote.model.drama.DramaUnlockMeta;

import java.util.List;

public class EpisodesUnlockedEvent {
    public final String dramaId;
    public final List<DramaUnlockMeta> metas;

    public EpisodesUnlockedEvent(String dramaId, List<DramaUnlockMeta> metas) {
        this.dramaId = dramaId;
        this.metas = metas;
    }

    public boolean has(String episodeId) {
        if (episodeId == null || metas == null || metas.isEmpty()) {
            return false;
        }
        for (DramaUnlockMeta meta : metas) {
            if (episodeId.equals(meta.vid)) {
                return true;
            }
        }

        return false;
    }

    public boolean has(int episodeNumber) {
        if (episodeNumber == 0 || metas == null || metas.isEmpty()) {
            return false;
        }
        for (DramaUnlockMeta meta : metas) {
            if (episodeNumber == meta.episodeNumber) {
                return true;
            }
        }

        return false;
    }
}
