// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewpager2;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import android.view.ViewParent;
import android.widget.FrameLayout;

import androidx.viewpager2.widget.ViewPager2;

/**
 * 解决 ViewPager2 相比 ViewPager 横向滑动更灵敏的问题
 */
public class ViewPager2ChildFrameLayout extends FrameLayout {
    private int mPagingTouchSlop;
    private int mTouchSlop;
    private float mInitX;
    private float mInitY;
    private ViewPager2 mParentPager;
    private boolean mViewPagerEnableScroll = false;

    public ViewPager2ChildFrameLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    public ViewPager2ChildFrameLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ViewPager2ChildFrameLayout(Context context) {
        this(context, null);
    }

    private void init(Context context) {
        ViewConfiguration configuration = ViewConfiguration.get(context);
        mPagingTouchSlop = configuration.getScaledPagingTouchSlop();
        mTouchSlop = configuration.getScaledTouchSlop();
    }

    private ViewPager2 getParentPager() {
        if (mParentPager == null) {
            ViewParent parent = getParent();
            while (parent != null && !(parent instanceof ViewPager2)) {
                parent = parent.getParent();
            }
            if (parent != null) {
                mParentPager = (ViewPager2) parent;
            }
        }
        return mParentPager;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        handleInterceptTouchEvent(e);
        return super.onInterceptTouchEvent(e);
    }

    private void handleInterceptTouchEvent(MotionEvent e) {
        final ViewPager2 pager = getParentPager();
        if (pager == null) return;

        int action = e.getAction() & MotionEvent.ACTION_MASK;
        if (action == MotionEvent.ACTION_CANCEL || action == MotionEvent.ACTION_UP) {
            mViewPagerEnableScroll = false;
            return;
        }

        if (action != MotionEvent.ACTION_DOWN && mViewPagerEnableScroll) {
            return;
        }

        if (e.getAction() == MotionEvent.ACTION_DOWN) {
            mInitX = e.getX();
            mInitY = e.getY();
            mViewPagerEnableScroll = false;
            getParent().requestDisallowInterceptTouchEvent(true);
        } else if (e.getAction() == MotionEvent.ACTION_MOVE) {
            float dx = e.getX() - mInitX;
            float dy = e.getY() - mInitY;
            boolean isViewPagerHorizontal = pager.getOrientation() == ViewPager2.ORIENTATION_HORIZONTAL;
            float absDx = Math.abs(dx);
            float absDy = Math.abs(dy);
            if (isViewPagerHorizontal) {
                if (absDy < mTouchSlop && absDx > mPagingTouchSlop && absDx * 0.5 > absDy) {
                    mViewPagerEnableScroll = true;
                    getParent().requestDisallowInterceptTouchEvent(false);
                }
            } else {
                if (absDx < mTouchSlop && absDy > mPagingTouchSlop && absDy * 0.5 > absDx) {
                    mViewPagerEnableScroll = true;
                    getParent().requestDisallowInterceptTouchEvent(false);
                }
            }
        }
    }
}



