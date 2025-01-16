// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.vod.minidrama.scene.widgets.impl.ViewPager2LoadMoreHelper;
import com.byteplus.minidrama.R;
import com.byteplus.vod.scenekit.ui.widgets.load.LoadMoreAble;
import com.byteplus.vod.scenekit.ui.widgets.load.RefreshAble;


public class DramaVideoSceneView implements RefreshAble, LoadMoreAble {

    private final SwipeRefreshLayout mRefreshLayout;

    private final ViewPager2LoadMoreHelper mLoadMoreHelper;
    private final DramaVideoPageView mPageView;

    private OnRefreshListener mRefreshListener;
    private OnLoadMoreListener mLoadMoreListener;

    public DramaVideoSceneView(@NonNull View view) {
        ViewPager2 viewPager = view.findViewById(R.id.vevod_view_pager);

        mPageView = new DramaVideoPageView(viewPager);
        // refresh
        mRefreshLayout = view.findViewById(R.id.vevod_refresh_view);
        mRefreshLayout.setRefreshing(false);
        mRefreshLayout.setOnRefreshListener(() -> {
            if (mRefreshListener != null) {
                mRefreshListener.onRefresh();
            }
        });
        // load more
        mLoadMoreHelper = new ViewPager2LoadMoreHelper(mPageView.viewPager());
        mLoadMoreHelper.setOnLoadMoreListener(() -> {
            if (mLoadMoreListener != null) {
                mLoadMoreListener.onLoadMore();
            }
        });
    }

    @Override
    public void setRefreshEnabled(boolean enabled) {
        mRefreshLayout.setEnabled(enabled);
    }

    @Override
    public boolean isRefreshEnabled() {
        return mRefreshLayout.isEnabled();
    }

    @Override
    public void setOnRefreshListener(OnRefreshListener listener) {
        this.mRefreshListener = listener;
    }

    @Override
    public boolean isRefreshing() {
        return mRefreshLayout.isRefreshing();
    }

    @Override
    public void showRefreshing() {
        mRefreshLayout.setRefreshing(true);
    }

    @Override
    public void dismissRefreshing() {
        mRefreshLayout.setRefreshing(false);
    }

    @Override
    public void setLoadMoreEnabled(boolean enabled) {
        mLoadMoreHelper.setLoadMoreEnabled(enabled);
    }

    @Override
    public boolean isLoadMoreEnabled() {
        return mLoadMoreHelper.isLoadMoreEnabled();
    }

    @Override
    public void setOnLoadMoreListener(OnLoadMoreListener listener) {
        mLoadMoreListener = listener;
    }

    @Override
    public boolean isLoadingMore() {
        return mLoadMoreHelper.isLoadingMore();
    }

    @Override
    public void showLoadingMore() {
        mLoadMoreHelper.showLoadingMore();
    }

    @Override
    public void dismissLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
    }

    @Override
    public void finishLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
    }

    public DramaVideoPageView pageView() {
        return mPageView;
    }

    public boolean onBackPressed() {
        return mPageView.onBackPressed();
    }
}
