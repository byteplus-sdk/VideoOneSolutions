/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.voddemo.ui.video.scene.comment;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.vod.scenekit.utils.UIUtils;

class ItemSpacerDecoration extends RecyclerView.ItemDecoration {

    private final int topInPixel;
    private final int innerInPixel;

    ItemSpacerDecoration(Context context, float topInDp, float innerInDp) {
        this.topInPixel = (int) UIUtils.dip2Px(context, topInDp);
        this.innerInPixel = (int) UIUtils.dip2Px(context, innerInDp);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        final int position = parent.getChildLayoutPosition(view);
        if (position == 0) {
            outRect.top = topInPixel;
        } else {
            outRect.top = innerInPixel;
        }
    }
}
