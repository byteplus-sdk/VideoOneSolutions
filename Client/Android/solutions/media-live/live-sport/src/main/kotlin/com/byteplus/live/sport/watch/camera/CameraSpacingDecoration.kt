// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.camera

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

/**
 * Adds a horizontal gap between camera items (no gap before the first / after
 * the last) so the fill-width calculation in [CameraListAdapter.setFillWidth]
 * lines up exactly with the rendered spacing.
 */
class CameraSpacingDecoration(private val gapPx: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State,
    ) {
        val position = parent.getChildAdapterPosition(view)
        outRect.right = if (position == (parent.adapter?.itemCount ?: 0) - 1) 0 else gapPx
    }
}
