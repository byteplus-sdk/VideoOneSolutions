// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.core.widget.ContentLoadingProgressBar;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.widgets.load.LoadMoreAble;
import com.byteplus.vod.scenekit.ui.widgets.load.RefreshAble;
import com.byteplus.vod.scenekit.ui.widgets.load.impl.ViewPager2LoadMoreHelper;

public class ShortVideoSceneView implements RefreshAble, LoadMoreAble {

    private final SwipeRefreshLayout mRefreshLayout;

    private final ViewPager2LoadMoreHelper mLoadMoreHelper;
    private final ShortVideoPageView mPageView;
    private final ContentLoadingProgressBar mLoadMoreProgressBar;

    private OnRefreshListener mRefreshListener;
    private OnLoadMoreListener mLoadMoreListener;

    public ShortVideoSceneView(@NonNull View view) {
        ViewPager2 viewPager2 = view.findViewById(R.id.vevod_view_pager);

        mPageView = new ShortVideoPageView(viewPager2);
        // refresh
        mRefreshLayout = view.findViewById(R.id.vevod_refresh_view);
        mRefreshLayout.setOnRefreshListener(() -> {
            if (mRefreshListener != null) {
                mRefreshListener.onRefresh();
            }
        });

        // load more
        mLoadMoreProgressBar = view.findViewById(R.id.vevod_load_more_progress_bar);
        mLoadMoreHelper = new ViewPager2LoadMoreHelper(viewPager2);
        mLoadMoreHelper.setOnLoadMoreListener(() -> {
            if (mLoadMoreListener != null) {
                mLoadMoreListener.onLoadMore();
            }
        });
    }

    // region RefreshAble
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
    // endregion

    // region LoadMoreAble
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
        mLoadMoreProgressBar.show();
    }

    @Override
    public void dismissLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
        mLoadMoreProgressBar.hide();
    }

    @Override
    public void finishLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
        mLoadMoreProgressBar.hide();
    }
    // endregion

    public ShortVideoPageView pageView() {
        return mPageView;
    }
}
