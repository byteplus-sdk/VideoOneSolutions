// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;

import java.util.ArrayList;
import java.util.List;

/** 可见项决定优先级，两侧一排分别用于准备前方和保留后方。 */
public final class HomePreloadWindow extends ArrayList<DramaInfo> {
    public final List<DramaInfo> forward = new ArrayList<>();
    public final List<DramaInfo> backward = new ArrayList<>();

    void collectAdjacent(RecyclerView recycler, List<DramaInfo> items, int direction) {
        if (items == null || items.isEmpty()) return;
        int first = RecyclerView.NO_POSITION;
        int last = RecyclerView.NO_POSITION;
        for (int i = 0; i < recycler.getChildCount(); i++) {
            View child = recycler.getChildAt(i);
            int position = recycler.getChildAdapterPosition(child);
            if (position < 0 || !child.isShown() || child.getAlpha() <= 0
                    || !child.getGlobalVisibleRect(new Rect())) continue;
            first = first < 0 ? position : Math.min(first, position);
            last = Math.max(last, position);
        }
        if (first < 0) return;
        int span = recycler.getLayoutManager() instanceof GridLayoutManager grid
                ? grid.getSpanCount() : 1;
        addAdjacent(items, first, last, span, direction);
    }

    void addAdjacent(List<DramaInfo> items, int first, int last, int span, int direction) {
        int before = first / span * span - span;
        int after = last / span * span + span;
        addRow(items, before, span, direction < 0 ? forward : backward);
        addRow(items, after, span, direction < 0 ? backward : forward);
    }

    private static void addRow(List<DramaInfo> items, int start, int span, List<DramaInfo> out) {
        for (int position = Math.max(0, start); position < start + span && position < items.size(); position++) {
            out.add(items.get(position));
        }
    }
}
