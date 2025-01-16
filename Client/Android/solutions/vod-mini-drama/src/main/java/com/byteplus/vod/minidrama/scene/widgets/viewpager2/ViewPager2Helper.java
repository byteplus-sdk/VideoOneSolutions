// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewpager2;

import android.view.View;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

public class ViewPager2Helper {

    public static void setup(ViewPager2 viewPager) {
        RecyclerView recyclerView = null;
        View view = viewPager.getChildAt(0);
        if (view instanceof RecyclerView) {
            recyclerView = (RecyclerView) view;
        }
        if (recyclerView == null) return;
        recyclerView.setScrollingTouchSlop(RecyclerView.TOUCH_SLOP_PAGING);
        recyclerView.setItemAnimator(null);
        recyclerView.setHasFixedSize(true);
    }

    @Nullable
    public static View findItemViewByPosition(ViewPager2 pager, int position) {
        final RecyclerView recyclerView = (RecyclerView) pager.getChildAt(0);
        if (recyclerView != null) {
            LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
            if (layoutManager != null) {
                return layoutManager.findViewByPosition(position);
            }
        }
        return null;
    }
}
