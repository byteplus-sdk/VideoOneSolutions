// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.vertcdemo.solution.interactivelive.util.ViewUtils;

public class LiveRoomItemDecoration extends RecyclerView.ItemDecoration {
    private final int spacing;

    private final int lastSpacing;

    public LiveRoomItemDecoration() {
        spacing = ViewUtils.dp2px(16);
        lastSpacing = ViewUtils.dp2px(114);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);

        final int itemPosition = parent.getChildAdapterPosition(view);
        if (itemPosition == RecyclerView.NO_POSITION) {
            return;
        }

        final int itemCount = state.getItemCount();
        if (itemCount > 0 && itemPosition == itemCount - 1) {
            outRect.bottom = lastSpacing;
        } else {
            outRect.bottom = spacing;
        }
    }
}
