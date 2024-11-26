// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class IndexedItem<T> {
    public final int index;
    public final T data;

    public IndexedItem(int index, T data) {
        this.index = index;
        this.data = data;
    }

    @NonNull
    public static <T> List<IndexedItem<T>> mapIndexed(List<T> items) {
        if (items == null || items.isEmpty()) {
            return Collections.emptyList();
        }

        List<IndexedItem<T>> indexed = new ArrayList<>(items.size());
        for (int i = 0; i < items.size(); i++) {
            indexed.add(new IndexedItem<>(i, items.get(i)));
        }

        return indexed;
    }
}
