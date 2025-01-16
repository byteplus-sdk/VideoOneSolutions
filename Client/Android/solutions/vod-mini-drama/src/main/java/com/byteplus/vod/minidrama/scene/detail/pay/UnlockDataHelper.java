// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import android.text.TextUtils;

import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class UnlockDataHelper {
    /**
     * All locked episodes
     */
    private final List<String> mAllLockedEpisodes;
    /**
     * From current episode to the end of the drama
     */
    private final List<String> mRemindLockedEpisodes;

    public UnlockDataHelper(DramaItem item, boolean fromUnlockAll) {
        List<ViewItem> viewItems = item.episodeVideoItems;
        if (viewItems == null || viewItems.isEmpty()) {
            mAllLockedEpisodes = Collections.emptyList();
            mRemindLockedEpisodes = Collections.emptyList();
            return;
        }

        mAllLockedEpisodes = new ArrayList<>();
        mRemindLockedEpisodes = new ArrayList<>();

        String currentEpisodeId = fromUnlockAll ? null : findCurrentEpisodeId(item);
        boolean start = fromUnlockAll || (currentEpisodeId == null);

        for (ViewItem viewItem : viewItems) {
            if (viewItem instanceof VideoItem videoItem) {
                DramaFeed feed = DramaFeed.of(videoItem);
                if (feed == null) continue;
                if (feed.isLocked()) {
                    mAllLockedEpisodes.add(feed.vid);
                }

                if (!start && TextUtils.equals(currentEpisodeId, feed.vid)) {
                    start = true;
                }

                if (start && feed.isLocked()) {
                    mRemindLockedEpisodes.add(feed.vid);
                }
            }
        }
    }

    public int getRemindLockedEpisodeCount() {
        return mRemindLockedEpisodes.size();
    }

    public int getTotalLockedEpisodeCount() {
        return mAllLockedEpisodes.size();
    }

    private static String findCurrentEpisodeId(DramaItem item) {
        if (item.currentItem instanceof VideoItem videoItem) {
            DramaFeed feed = DramaFeed.of(videoItem);
            if (feed != null) {
                return feed.vid;
            }
        }
        return null;
    }

    public List<String> getEpisodes(int unlockCount) {
        return mRemindLockedEpisodes.subList(0, unlockCount);
    }

    public List<String> allEpisodes() {
        return Collections.unmodifiableList(mAllLockedEpisodes);
    }

    public static boolean hasLocked(DramaItem item) {
        List<ViewItem> viewItems = item.episodeVideoItems;
        if (viewItems == null || viewItems.isEmpty()) {
            return false;
        }
        for (ViewItem viewItem : viewItems) {
            if (viewItem instanceof VideoItem videoItem) {
                DramaFeed feed = DramaFeed.of(videoItem);
                if (feed != null && feed.isLocked()) {
                    return true;
                }
            }
        }
        return false;
    }
}
