// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import com.byteplus.vod.minidrama.scene.widgets.adatper.Comparator;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.data.model.VideoItem;

public class ItemHelper {

    private static final Comparator<ViewItem> ITEM_COMPARATOR = new Comparator<ViewItem>() {
        @Override
        public boolean compare(ViewItem o1, ViewItem o2) {
            if (o1 == o2) {
                return true;
            }
            if (o1 instanceof VideoItem && o2 instanceof VideoItem) {
                return VideoItem.itemEquals((VideoItem) o1, (VideoItem) o2);
            }
            return false;
        }
    };

    public static Comparator<ViewItem> comparator() {
        return ITEM_COMPARATOR;
    }
}
