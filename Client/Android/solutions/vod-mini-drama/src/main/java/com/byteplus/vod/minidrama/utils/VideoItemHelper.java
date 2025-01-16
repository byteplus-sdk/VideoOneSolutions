// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import androidx.annotation.NonNull;
import androidx.core.util.Predicate;

import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.data.model.ItemType;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class VideoItemHelper {
    @NonNull
    public static List<VideoItem> findVideoItems(List<? extends ViewItem> items) {
        if (items == null) return Collections.emptyList();
        final List<VideoItem> videoItems = new ArrayList<>();
        for (ViewItem item : items) {
            if (item.itemType() == ItemType.ITEM_TYPE_VIDEO) {
                videoItems.add((VideoItem) item);
            }
        }
        return videoItems;
    }

    public static VideoItem findVideoItem(ViewItem item) {
        if (item == null) return null;
        if (item.itemType() == ItemType.ITEM_TYPE_VIDEO) {
            return (VideoItem) item;
        }
        return null;
    }

    public static List<VideoItem> filter(@NonNull List<VideoItem> items,
                                         @NonNull Predicate<VideoItem> predicate) {
        if (items.isEmpty()) {
            return Collections.emptyList();
        }

        List<VideoItem> result = new ArrayList<>();

        for (VideoItem item : items) {
            if (predicate.test(item)) {
                result.add(item);
            }
        }
        return result;
    }
}
