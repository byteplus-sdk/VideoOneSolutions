// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.widgets.viewpager2;

import android.util.SparseIntArray;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.playerkit.utils.L;

import java.lang.ref.WeakReference;

public abstract class OnPageChangeCallbackCompat extends ViewPager2.OnPageChangeCallback {

    public static final int RETRY_COUNT = 10;

    public WeakReference<ViewPager2> mViewPagerRef;
    private final SparseIntArray mPageSelectedTryInvokeCounts = new SparseIntArray();

    public OnPageChangeCallbackCompat(ViewPager2 viewPager) {
        this.mViewPagerRef = new WeakReference<>(viewPager);
    }

    @Override
    public final void onPageSelected(int position) {
        final ViewPager2 viewPager = mViewPagerRef.get();
        if (viewPager == null) return;

        View view = null;
        final RecyclerView recyclerView = (RecyclerView) viewPager.getChildAt(0);
        if (recyclerView != null) {
            LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
            if (layoutManager != null) {
                view = layoutManager.findViewByPosition(position);
            }
        }
        int retryCountAtPos = mPageSelectedTryInvokeCounts.get(position);
        if (view == null && retryCountAtPos < RETRY_COUNT) {
            mPageSelectedTryInvokeCounts.put(position, ++retryCountAtPos);
            L.i(this, "onPageSelected", viewPager, position, "retry", retryCountAtPos);
            viewPager.postDelayed(() -> {
                onPageSelected(position);
            }, 10);
            return;
        }
        mPageSelectedTryInvokeCounts.put(position, 0);
        onPageSelected(position, viewPager);
    }

    public void onPageSelected(int position, ViewPager2 pager) {
    }
}
