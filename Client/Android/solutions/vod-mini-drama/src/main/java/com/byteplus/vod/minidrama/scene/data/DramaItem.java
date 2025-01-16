// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.data;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.model.drama.DramaUnlockMeta;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DramaItem implements Serializable {

    public final DramaInfo dramaInfo;
    public int currentEpisodeNumber;
    public ViewItem currentItem;
    public List<ViewItem> episodeVideoItems;
    public boolean episodesAllLoaded;
    public ViewItem lastUnlockedItem;

    public DramaItem(DramaInfo dramaInfo, int currentEpisodeNumber) {
        this.dramaInfo = dramaInfo;
        this.currentEpisodeNumber = currentEpisodeNumber;
    }

    @NonNull
    public String getDramaId() {
        return dramaInfo.dramaId;
    }

    public String getCoverUrl() {
        return dramaInfo.dramaCoverUrl;
    }

    public String getDramaTitle() {
        return dramaInfo.dramaTitle;
    }

    public int getTotalEpisodeNumber() {
        return dramaInfo.totalEpisodeNumber;
    }

    @Nullable
    public String getCurrentEpisodeId() {
        if (currentItem instanceof VideoItem videoItem) {
            return videoItem.getVid();
        }

        return null;
    }

    public static String dump(DramaItem dramaItem) {
        if (dramaItem == null) return null;
        return dramaItem.dramaInfo.toString();
    }

    public static List<DramaItem> createByDramaInfos(List<DramaInfo> dramaInfos) {
        final List<DramaItem> items = new ArrayList<>();
        for (DramaInfo info : dramaInfos) {
            items.add(new DramaItem(info, 1));
        }
        return items;
    }

    public static int findDramaItemPosition(List<DramaItem> dramaItems, ViewItem item) {
        for (int i = 0; dramaItems != null && i < dramaItems.size(); i++) {
            DramaItem dramaItem = dramaItems.get(i);
            if (dramaItem != null && dramaItem.currentItem == item) {
                return i;
            }
        }
        return -1;
    }

    public int updateCurrent(ViewItem item, int episodeNumber) {
        currentItem = item;
        int oldEpisodeNumber = currentEpisodeNumber;
        currentEpisodeNumber = episodeNumber;
        return oldEpisodeNumber;
    }

    public void unlock(List<DramaUnlockMeta> metas) {
        List<ViewItem> viewItems = episodeVideoItems;
        if (viewItems == null || viewItems.isEmpty()) return;

        Map<String, VideoItem> videoItemMap = asMap(viewItems);

        for (DramaUnlockMeta meta : metas) {
            VideoItem videoItem = videoItemMap.get(meta.vid);
            if (videoItem == null) continue;
            videoItem.updatePlayAuthToken(meta.playAuthToken);
            videoItem.updateSubtitleAuthToken(meta.subtitleAuthToken);
            DramaFeed feed = DramaFeed.of(videoItem);
            feed.updatePlayAuthToken(meta.playAuthToken);
            feed.updateSubtitleAuthToken(meta.subtitleAuthToken);
        }
    }

    public boolean isLastEpisode(ViewItem item) {
        if (episodeVideoItems == null || episodeVideoItems.isEmpty()) return false;
        return item == episodeVideoItems.get(episodeVideoItems.size() - 1);
    }

    public static Map<String, VideoItem> asMap(@NonNull List<ViewItem> viewItems) {
        Map<String, VideoItem> items = new HashMap<>();
        for (ViewItem viewItem : viewItems) {
            if (viewItem instanceof VideoItem videoItem) {
                items.put(videoItem.getVid(), videoItem);
            }
        }
        return items;
    }
}

