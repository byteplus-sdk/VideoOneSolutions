// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.widgets.load;

public interface RefreshAble {

    void setRefreshEnabled(boolean enabled);

    boolean isRefreshEnabled();

    void setOnRefreshListener(OnRefreshListener listener);

    boolean isRefreshing();

    void showRefreshing();

    void dismissRefreshing();

    interface OnRefreshListener {
        void onRefresh();
    }
}
