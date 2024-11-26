// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.feedvideo;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.scene.utils.FeedStrategySettingsConfig;
import com.byteplus.vod.scenekit.ui.widgets.load.LoadMoreAble;
import com.byteplus.vod.scenekit.ui.widgets.load.RefreshAble;
import com.byteplus.vod.scenekit.ui.widgets.load.impl.RecycleViewLoadMoreHelper;

public class FeedVideoSceneView extends FrameLayout implements RefreshAble, LoadMoreAble {
    private final FeedVideoPageView mPageView;
    private final SwipeRefreshLayout mRefreshLayout;

    private final RecycleViewLoadMoreHelper mLoadMoreHelper;

    private RefreshAble.OnRefreshListener mRefreshListener;
    private LoadMoreAble.OnLoadMoreListener mLoadMoreListener;

    public FeedVideoSceneView(@NonNull Context context) {
        this(context, null, 0, new FeedStrategySettingsConfig());
    }

    public FeedVideoSceneView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0, new FeedStrategySettingsConfig());
    }

    public FeedVideoSceneView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, new FeedStrategySettingsConfig());
    }

    public FeedVideoSceneView(@NonNull Context context, @NonNull IFeedVideoStrategyConfig strategyConfig) {
        this(context, null, 0, strategyConfig);
    }

    private FeedVideoSceneView(@NonNull Context context,
                               @Nullable AttributeSet attrs,
                               int defStyleAttr,
                               @NonNull IFeedVideoStrategyConfig strategyConfig) {
        super(context, attrs, defStyleAttr);

        RecyclerView recyclerView = new RecyclerView(context);
        recyclerView.setId(R.id.vevod_recycler_view);

        mRefreshLayout = new SwipeRefreshLayout(context);
        mRefreshLayout.setId(R.id.vevod_refresh_view);
        mRefreshLayout.setOnRefreshListener(() -> {
            if (mRefreshListener != null) {
                mRefreshListener.onRefresh();
            }
        });
        mRefreshLayout.addView(recyclerView, new SwipeRefreshLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        addView(mRefreshLayout, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

        mPageView = new FeedVideoPageView(mRefreshLayout, strategyConfig);

        mLoadMoreHelper = new RecycleViewLoadMoreHelper(recyclerView);
        mLoadMoreHelper.setOnLoadMoreListener(() -> {
            if (mLoadMoreListener != null) {
                mLoadMoreListener.onLoadMore();
            }
        });
    }

    public void setDetailPageNavigator(FeedVideoPageView.DetailPageNavigator navigator) {
        mPageView.setDetailPageNavigator(navigator);
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
        this.mLoadMoreListener = listener;
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
        mLoadMoreHelper.finishLoadingMore();
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

    public FeedVideoPageView pageView() {
        return mPageView;
    }

    public boolean onBackPressed() {
        return mPageView.onBackPressed();
    }
}
