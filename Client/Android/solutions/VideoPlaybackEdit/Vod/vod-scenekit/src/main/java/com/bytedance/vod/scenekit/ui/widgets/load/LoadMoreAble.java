// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.widgets.load;

public interface LoadMoreAble {

    void setLoadMoreEnabled(boolean enabled);

    boolean isLoadMoreEnabled();

    void setOnLoadMoreListener(OnLoadMoreListener listener);

    boolean isLoadingMore();

    void showLoadingMore();

    void dismissLoadingMore();

    void finishLoadingMore();

    interface OnLoadMoreListener {
        void onLoadMore();
    }
}
