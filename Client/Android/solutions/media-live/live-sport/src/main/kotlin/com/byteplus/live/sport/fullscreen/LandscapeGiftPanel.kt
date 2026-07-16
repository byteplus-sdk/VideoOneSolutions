// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.byteplus.live.sport.R
import com.byteplus.live.sport.watch.panel.GiftBinder

/**
 * Landscape (right-side slide) gift panel. Reuses the shared gift grid content
 * inside a side panel; the card uses a left-rounded dark background since it
 * docks to the right edge.
 */
class LandscapeGiftPanel(
    activity: Activity,
    private val onSend: (GiftBinder.Gift) -> Unit,
) : LandscapeSidePanel(
    activity = activity,
    widthPx = (activity.resources.displayMetrics.density * PANEL_WIDTH_DP).toInt(),
) {

    override fun onCreateContent(inflater: LayoutInflater): View {
        val content = inflater.inflate(R.layout.live_sport_panel_gift, null, false)
        content.setBackgroundResource(R.drawable.live_sport_gift_panel_landscape_bg)
        content.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
        )
        return content
    }

    override fun onBind(content: View) {
        GiftBinder.bind(
            content = content,
            spanCount = 3,
            onSend = {
                onSend(it)
                dismiss()
            },
        )
    }

    private companion object {
        const val PANEL_WIDTH_DP = 360f
    }
}
