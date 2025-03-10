// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.byteplus.live.common.DensityUtils;
import com.byteplus.live.common.dialog.SettingsDialog;
import com.google.android.material.tabs.TabLayout;

import java.util.List;

public abstract class SettingsDialogWithTab extends SettingsDialog {
    public SettingsDialogWithTab(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUI();
    }

    public abstract int[] getTabNames();

    public abstract List<View> generateTabViews();

    private void initUI() {
        Context context = getContext();
        ViewPager viewPager = new ViewPager(context);
        viewPager.setAdapter(new TabViewPageAdapter(context, getTabNames(), generateTabViews()));

        mContainer.setOrientation(LinearLayout.VERTICAL);
        mContainer.setBackgroundResource(com.byteplus.live.common.R.drawable.live_shape_basic_item_r10);
        mContainer.addView(createTabLayout(viewPager));
        LinearLayout.LayoutParams viewPagerParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0
        );
        viewPagerParams.weight = 1;
        viewPagerParams.leftMargin = viewPagerParams.rightMargin = DensityUtils.dip2px(getContext(), 10);
        mContainer.addView(viewPager, viewPagerParams);
    }

    private ScrollView createScrollView(ViewPager viewPager) {
        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.addView(viewPager);

        ScrollView scrollView = new ScrollView(getContext());
        scrollView.setPadding(DensityUtils.dip2px(getContext(), 10), DensityUtils.dip2px(getContext(), 10), DensityUtils.dip2px(getContext(), 10), 0);
        scrollView.setFillViewport(true);
        scrollView.addView(layout);

        LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) viewPager.getLayoutParams();
        lp.height = 500 * 3;
        viewPager.setLayoutParams(lp);
        return scrollView;
    }

    private TabLayout createTabLayout(ViewPager viewPager) {
        Context context = getContext();
        TabLayout tabLayout = new TabLayout(context);
        int normalColor = ContextCompat.getColor(context, com.byteplus.live.common.R.color.live_bg_white);
        int selectedColor = ContextCompat.getColor(context, com.byteplus.live.common.R.color.live_bg_blue);
        tabLayout.setTabTextColors(normalColor, selectedColor);
        tabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);
        tabLayout.setTabIndicatorFullWidth(false);
        tabLayout.setBackgroundColor(Color.TRANSPARENT);
        tabLayout.setSelectedTabIndicatorColor(ContextCompat.getColor(context, com.byteplus.live.common.R.color.live_bg_blue));
        tabLayout.setupWithViewPager(viewPager);
        return tabLayout;
    }

    static class TabViewPageAdapter extends PagerAdapter {
        private final int[] mTitles;
        private final List<View> mViews;

        private final Context mContext;

        public TabViewPageAdapter(Context context, int[] titles, List<View> views) {
            mContext = context;
            mTitles = titles;
            mViews = views;
        }

        @Override
        public int getCount() {
            return mTitles.length;
        }

        @Override
        public boolean isViewFromObject(@NonNull View view, @NonNull Object object) {
            return view == object;
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            container.addView(mViews.get(position), new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT));
            return mViews.get(position);
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
            container.removeView((View) object);
        }


        @Override
        public CharSequence getPageTitle(int position) {
            return mContext.getText(mTitles[position]);
        }

        @Override
        public void setPrimaryItem(@NonNull ViewGroup container, int position, @NonNull Object object) {

        }
    }
}
