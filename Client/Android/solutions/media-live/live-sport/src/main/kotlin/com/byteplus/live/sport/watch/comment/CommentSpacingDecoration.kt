// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.comment

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

/** Vertical spacing between live-comment rows. Caller passes a px value. */
class CommentSpacingDecoration(private val spacingPx: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State,
    ) {
        val pos = parent.getChildAdapterPosition(view)
        if (pos > 0) outRect.top = spacingPx
    }
}
