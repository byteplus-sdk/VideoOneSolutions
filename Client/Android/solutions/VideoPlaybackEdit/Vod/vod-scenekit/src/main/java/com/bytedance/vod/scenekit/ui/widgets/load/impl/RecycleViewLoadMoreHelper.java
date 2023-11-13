// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.widgets.load.impl;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.vod.scenekit.ui.widgets.load.LoadMoreAble;

public class RecycleViewLoadMoreHelper implements LoadMoreAble {
    private final RecyclerView mRecyclerView;
    private boolean mLoadingMore;
    private boolean mLoadMoreEnabled = true;
    private OnLoadMoreListener mOnLoadMoreListener;

    public RecycleViewLoadMoreHelper(RecyclerView mRecyclerView) {
        this.mRecyclerView = mRecyclerView;
        this.mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                if (!isLoadMoreEnabled()) return;
                if (canTriggerLoadMore() && mOnLoadMoreListener != null) {
                    mOnLoadMoreListener.onLoadMore();
                }
            }
        });
    }

    @Override
    public void setLoadMoreEnabled(boolean enabled) {
        mLoadMoreEnabled = enabled;
    }

    @Override
    public boolean isLoadMoreEnabled() {
        return mLoadMoreEnabled;
    }

    @Override
    public void setOnLoadMoreListener(OnLoadMoreListener listener) {
        this.mOnLoadMoreListener = listener;
    }

    @Override
    public boolean isLoadingMore() {
        return mLoadingMore;
    }

    @Override
    public void showLoadingMore() {
        mLoadingMore = true;
    }

    @Override
    public void dismissLoadingMore() {
        mLoadingMore = false;
    }

    @Override
    public void finishLoadingMore() {
        mLoadingMore = false;
    }

    protected boolean canTriggerLoadMore() {
        LinearLayoutManager linearLayoutManager = (LinearLayoutManager) mRecyclerView.getLayoutManager();
        int lastVisiblePosition = linearLayoutManager.findLastVisibleItemPosition();
        return lastVisiblePosition + 2 >= mRecyclerView.getAdapter().getItemCount()
                && !mLoadingMore;
    }
}
