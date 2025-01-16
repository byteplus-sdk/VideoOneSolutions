// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewpager2;

import android.util.SparseIntArray;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;


import com.byteplus.vod.minidrama.utils.L;

import java.lang.ref.WeakReference;

/**
 * 1. 解决 ViewPager2 onPageSelected 回调了，但是通过 position 找不到 ItemView 的问题。
 * 2. 封装 onPagePeekStart 方便预渲染使用
 */
public abstract class OnPageChangeCallbackCompat extends ViewPager2.OnPageChangeCallback {

    public static final int RETRY_COUNT = 10;

    private final WeakReference<ViewPager2> mViewPagerRef;
    private final SparseIntArray mPageSelectedTryInvokeCounts = new SparseIntArray();

    private boolean mPeekStart;
    private int mPeekPosition;
    private int mLastPosition = -1;

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

        if (mLastPosition != position) {
            onPageSelected(viewPager, position);
            mLastPosition = position;
        }
    }

    @Override
    public final void onPageScrollStateChanged(int state) {
        final ViewPager2 viewPager = mViewPagerRef.get();
        if (viewPager == null) return;

        onPageScrollStateChanged(viewPager, state);

        if (state == ViewPager2.SCROLL_STATE_IDLE && mPeekStart) {
            mPeekStart = false;
            onPagePeekEnd(viewPager, viewPager.getCurrentItem(), mPeekPosition);
        }
    }

    @Override
    public final void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
        final ViewPager2 viewPager = mViewPagerRef.get();
        if (viewPager == null) return;

        onPageScrolled(viewPager, position, positionOffset, positionOffsetPixels);

        if (!mPeekStart) {
            if (positionOffset > 0) {
                mPeekStart = true;
                mPeekPosition = positionOffset > 0.5 ? position - 1 : position + 1;
                onPagePeekStart(viewPager, position, mPeekPosition);
            }
        }
    }

    public void onPageSelected(ViewPager2 pager, int position) {
        L.d(this, "onPageSelected", pager, "position=" + pager.getCurrentItem());
    }

    public void onPageScrollStateChanged(ViewPager2 pager, int state) {
        L.d(this, "onPageScrollStateChanged", "state=" + state);
    }

    public void onPageScrolled(ViewPager2 pager, int position, float positionOffset, int positionOffsetPixels) {
        //L.v(this, "onPageScrolled", pager, "position=" + position, "positionOffset=" + positionOffset, "positionOffsetPixels=" + positionOffsetPixels);
    }

    public void onPagePeekStart(ViewPager2 pager, int position, int peekPosition) {
        L.d(this, "onPagePeekStart", pager, "position=" + position, "peekPosition=" + peekPosition);
    }

    public void onPagePeekEnd(ViewPager2 pager, int position, int peekPosition) {
        L.d(this, "onPagePeekEnd", pager, "position=" + position, "peekPosition=" + peekPosition);
    }
}
