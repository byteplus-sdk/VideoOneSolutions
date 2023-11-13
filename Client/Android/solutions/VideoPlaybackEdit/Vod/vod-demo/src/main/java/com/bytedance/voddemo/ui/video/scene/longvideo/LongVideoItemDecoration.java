// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.video.scene.longvideo;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.vod.scenekit.utils.UIUtils;


public class LongVideoItemDecoration extends RecyclerView.ItemDecoration {
    final int headerBottom;

    final int groupTitleTop;

    final int itemMarginHorizontal;

    final int itemGap;
    final int itemBottom;

    public LongVideoItemDecoration(Context context) {
        headerBottom = (int) UIUtils.dip2Px(context, 18);
        groupTitleTop = (int) UIUtils.dip2Px(context, 6);
        itemMarginHorizontal = (int) UIUtils.dip2Px(context, 12);
        itemGap = (int) UIUtils.dip2Px(context, 12);
        itemBottom = (int) UIUtils.dip2Px(context, 14);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        final int position = parent.getChildAdapterPosition(view);
        final RecyclerView.Adapter<?> adapter = parent.getAdapter();
        final int type = adapter.getItemViewType(position);
        if (type == LongVideoAdapter.Item.TYPE_HEADER_BANNER) {
            outRect.set(0, 0, 0, headerBottom);
        } else if (type == LongVideoAdapter.Item.TYPE_GROUP_TITLE) {
            outRect.set(0, groupTitleTop, 0, 0);
        } else if (type == LongVideoAdapter.Item.TYPE_VIDEO_ITEM) {
            int titlePosition = -1;
            for (int i = position - 1; i >= 0; i--) {
                int viewType = adapter.getItemViewType(i);
                if (viewType == LongVideoAdapter.Item.TYPE_GROUP_TITLE) {
                    titlePosition = i;
                    break;
                }
            }
            int relativePosition = position - titlePosition - 1;
            final int left;
            final int right;
            if (relativePosition % 2 == 0) {
                left = itemMarginHorizontal;
                right = itemGap / 2;
            } else {
                left = itemGap / 2;
                right = itemMarginHorizontal;
            }
            outRect.set(left, 0, right, itemBottom);
        } else {
            outRect.set(0, 0, 0, 0);
        }
    }
}
