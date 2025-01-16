// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.carousel;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.GradientDrawable;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.theater.IDramaTheaterClickListener;
import com.byteplus.minidrama.R;
import com.byteplus.vod.scenekit.utils.ViewUtils;

import java.util.ArrayList;
import java.util.List;

public class DramaCarouselView extends FrameLayout {
    static final int MSG_AUTO_SCROLL = 100;
    static final int AUTO_SCROLL_INTERVAL = 3000;

    private final Handler mHandler = new Handler(Looper.getMainLooper(), new Handler.Callback() {
        @Override
        public boolean handleMessage(@NonNull Message msg) {
            if (msg.what == MSG_AUTO_SCROLL) {
                int position = mViewPager2.getCurrentItem();
                int newPosition = mCarouselAdapter.next(position);
                mViewPager2.setCurrentItem(newPosition, true);
            }
            return false;
        }
    });

    final float scale = 0.23f;
    final float minAlpha = 0.4f;
    final int itemSpace = ViewUtils.dp2px(16);

    private ViewPager2 mViewPager2;
    private DramaCarouselAdapter mCarouselAdapter;
    private IndicatorAdapter mIndicatorAdapter;
    private int mHorizontalMarginPx = -1;

    public DramaCarouselView(@NonNull Context context) {
        this(context, null);
    }

    public DramaCarouselView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DramaCarouselView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    public DramaCarouselView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initViews(context);
    }

    private void initViews(Context context) {
        LayoutInflater.from(context).inflate(R.layout.vevod_mini_drama_carousel_view, this);
        mCarouselAdapter = new DramaCarouselAdapter();
        mViewPager2 = findViewById(R.id.drama_carousel_viewpager2);
        mViewPager2.setAdapter(mCarouselAdapter);
        mViewPager2.setOffscreenPageLimit(1);
        mViewPager2.setPageTransformer((page, position) -> {
            float targetScale = 1 - (scale * Math.abs(position));
            final int nearItemVisiblePx = (int) (getHorizontalMarginPx() - itemSpace + page.getWidth() * (1 - targetScale) * 0.5f);
            final int pageTranslationX = nearItemVisiblePx + getHorizontalMarginPx();
            page.setTranslationX(-pageTranslationX * position);
            page.setScaleX(targetScale);
            page.setScaleY(targetScale);
            page.setTranslationY(page.getHeight() * ((scale * Math.abs(position)) * 0.5f));
            page.setAlpha(minAlpha + (1 - Math.abs(position)));
        });

        mViewPager2.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                outRect.set(getHorizontalMarginPx(), 0, getHorizontalMarginPx(), 0);
            }
        });
        mViewPager2.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {

            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                int indicatorCount = mIndicatorAdapter.getItemCount();
                int mIndicatorPosition = position % indicatorCount;
                mIndicatorAdapter.setCurrentPosition(mIndicatorPosition);
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                super.onPageScrollStateChanged(state);
                int itemCount = mCarouselAdapter.getItemCount();
                if (itemCount > 1) {
                    if (state == ViewPager2.SCROLL_STATE_IDLE) {
                        setCarouselAutoScroll(true);
                    } else if (state == ViewPager2.SCROLL_STATE_DRAGGING) {
                        setCarouselAutoScroll(false);
                    }
                }
            }
        });


        RecyclerView indicatorRecyclerView = findViewById(R.id.drama_carousel_indicator_recyclerview);
        LinearLayoutManager indicatorLayoutManager = new LinearLayoutManager(context, RecyclerView.HORIZONTAL, false);
        indicatorRecyclerView.setLayoutManager(indicatorLayoutManager);
        indicatorRecyclerView.setNestedScrollingEnabled(false);
        mIndicatorAdapter = new IndicatorAdapter();
        indicatorRecyclerView.setAdapter(mIndicatorAdapter);
    }

    private int getHorizontalMarginPx() {
        if (mHorizontalMarginPx == -1) {
            int height = mViewPager2.getHeight();
            int width = mViewPager2.getWidth();
            if (height <= 0 || width <= 0) {
                return 0;
            }
            mHorizontalMarginPx = (int) ((width - height * (260f / 347f)) * 0.5f);
        }
        return mHorizontalMarginPx;
    }

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mCarouselAdapter.setDramaClickListener(listener);
        mIndicatorAdapter.setIndicatorCount(items.size());
        mCarouselAdapter.submitList(items);
        int position = mCarouselAdapter.centerPosition();
        if (position >= 0) {
            mViewPager2.setCurrentItem(position, false);
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        setCarouselAutoScroll(true);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        setCarouselAutoScroll(false);
    }

    @Override
    protected void onWindowVisibilityChanged(int visibility) {
        super.onWindowVisibilityChanged(visibility);
        setCarouselAutoScroll(visibility == VISIBLE);
    }

    private void setCarouselAutoScroll(boolean start) {
        if (start) {
            mHandler.removeMessages(MSG_AUTO_SCROLL);
            mHandler.sendEmptyMessageDelayed(MSG_AUTO_SCROLL, AUTO_SCROLL_INTERVAL);
        } else {
            mHandler.removeMessages(MSG_AUTO_SCROLL);
        }
    }

    static class IndicatorAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

        private final GradientDrawable mActiveDrawable;
        private final GradientDrawable mInactiveDrawable;
        private final int mMargin = ViewUtils.dp2px(2);

        private int mCount = 0;
        private int mCurrentPosition = 0;

        public IndicatorAdapter() {
            int activeWidth = ViewUtils.dp2px(20);
            int inactiveWidth = ViewUtils.dp2px(12);
            int height = ViewUtils.dp2px(4);
            int cornerRadius = ViewUtils.dp2px(2);

            mActiveDrawable = new GradientDrawable();
            mActiveDrawable.setShape(GradientDrawable.RECTANGLE);
            mActiveDrawable.setColor(Color.WHITE);
            mActiveDrawable.setSize(activeWidth, height);
            mActiveDrawable.setCornerRadius(cornerRadius);

            mInactiveDrawable = new GradientDrawable();
            mInactiveDrawable.setShape(GradientDrawable.RECTANGLE);
            mInactiveDrawable.setColor(0x66FFFFFF);
            mInactiveDrawable.setSize(inactiveWidth, height);
            mInactiveDrawable.setCornerRadius(cornerRadius);
        }

        public void setCurrentPosition(int position) {
            if (position == mCurrentPosition) {
                return;
            }
            int oldPos = mCurrentPosition;
            mCurrentPosition = position;
            if (oldPos >= 0 && oldPos < mCount) {
                notifyItemChanged(oldPos);
            }
            notifyItemChanged(mCurrentPosition);
        }

        public void setIndicatorCount(int count) {
            if (mCount == count) {
                return;
            }
            mCurrentPosition = RecyclerView.NO_POSITION;
            mCount = 0;
            int diff = count - mCount;
            mCount = count;
            if (diff > 0) {
                notifyItemRangeInserted(0, diff);
            } else {
                notifyItemRangeRemoved(0, -diff);
            }
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            ImageView imageView = new ImageView(parent.getContext());
            LayoutParams layoutParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            layoutParams.setMargins(mMargin, 0, mMargin, 0);
            imageView.setLayoutParams(layoutParams);
            return new RecyclerView.ViewHolder(imageView) {
            };
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ImageView imageView = (ImageView) holder.itemView;
            imageView.setImageDrawable(mCurrentPosition == position ? mActiveDrawable : mInactiveDrawable);
        }

        @Override
        public int getItemCount() {
            return mCount;
        }
    }
}
