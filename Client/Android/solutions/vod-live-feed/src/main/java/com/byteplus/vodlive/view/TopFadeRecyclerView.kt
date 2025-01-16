// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.view

import android.content.Context
import android.util.AttributeSet
import androidx.recyclerview.widget.RecyclerView

class TopFadeRecyclerView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : RecyclerView(context, attrs, defStyleAttr) {
    override fun getBottomFadingEdgeStrength() = 0F
}