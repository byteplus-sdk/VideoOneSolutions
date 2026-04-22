// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app.function

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class FunctionItemDecoration(private val top: Int, private val spacing: Int) :
    RecyclerView.ItemDecoration() {
    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State
    ) {
        val position = parent.getChildAdapterPosition(view)
        if (position == RecyclerView.NO_POSITION) return;
        outRect.top = if (position == 0) top else 0
        outRect.bottom = spacing
    }
}