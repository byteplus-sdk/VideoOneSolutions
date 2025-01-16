// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.selector;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.selector.model.IndexItem;
import com.byteplus.vod.minidrama.scene.detail.selector.model.Range;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.ArrayList;
import java.util.List;

public class IndexItemViewModel extends ViewModel {
    public MutableLiveData<List<IndexItem>> indexItems = new MutableLiveData<>();
    @NonNull
    public Range range = Range.ZERO;

    @Nullable
    private DramaItem dramaItem;

    @NonNull
    public String getDramaId() {
        return dramaItem == null ? "" : dramaItem.getDramaId();
    }

    public void setRange(DramaItem dramaItem, @NonNull Range range) {
        this.range = range;
        this.dramaItem = dramaItem;

        ArrayList<IndexItem> items = new ArrayList<>();

        // Assume episodeVideoItems is sorted by episode number.
        for (int i = (range.from - 1); i < range.to; i++) {
            DramaFeed feed = DramaFeed.of((VideoItem) dramaItem.episodeVideoItems.get(i));
            IndexItem indexItem = new IndexItem(feed.episodeNumber);
            indexItem.locked = feed.isLocked();
            indexItem.playing = feed.episodeNumber == dramaItem.currentEpisodeNumber;
            items.add(indexItem);
        }

        indexItems.postValue(items);
    }
}
